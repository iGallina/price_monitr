# encoding: utf-8

require 'rubygems'
require 'yaml'
require 'cgi'

require_relative 'db'
require_relative 'crawler'
require_relative 'notifier'


class PriceMonitr
  
  DAY_IN_SECS = 86400
  
  def initialize
    # instancia o DBUtil
    @db_util = DBUtil.new
    @scraper = Scraper::SearchScraper.new
    @twitter = TwitterNotifier.new
  end
  
  def executar!
    # le da yml quais sites a serem analisados
    @sites = YAML::load_file('/home/price/sites.yml')
    #@sites = YAML::load_file('sites.yml')
    @regras = YAML::load_file('regras.yml')

    @sites.each do |site|
      #Recupera as regras desse site
      regras = @regras[site[0]]

      base_url = site[1]['base_url']
      regra_preco = regras['regra_preco']
      regra_estoque = regras['regra_estoque']

      #Recupera os tipos diferentes de regras desse site
      tipos_regras = regras['tipos']

      produtos = site[1]['produtos']
      produtos.each do |produto|
        key = produto[0]
        produto_url = produto[1]['url']
        nome = produto[1]['nome']
        rules = produto[1]['rules']
        
        # verifica se o produto sobrescreve as regras de preço
        if produto[1]['tipo']
          #Verifica se tem a regra mapeada
          if !tipos_regras || !tipos_regras[produto[1]['tipo']]
            msg_error = "[ERRO] A regra '#{produto[1]['tipo']}' não existe para o site #{tinyurl(base_url+produto_url)}! Verifique o arquivo sites.yml."
            #chamar o notifier.rb para falar que a yml está errada
            @twitter.post msg_error
            
            next
          end
          
          #Verifica a regra do preço
          regra_temp = tipos_regras[produto[1]['tipo']]['regra_preco']
          
          #Verifica se foi informado a regra especifica de preco no produto
          if regra_temp
            regra_preco_produto = regra_temp
          else
            regra_preco_produto = regra_preco
          end
          
          #Verifica a regra do estoque
          regra_temp = tipos_regras[produto[1]['tipo']]['regra_estoque']
          
          #Verifica se foi informado a regra especifica de estoque no produto
          if regra_temp
            regra_estoque_produto = regra_temp
          else
            regra_estoque_produto = regra_estoque
          end
          
        else
          regra_preco_produto = regra_preco
          regra_estoque_produto = regra_estoque
        end

        # acessa o site e recupera os dados
        time = Time.now
        if produto[1]['tipo']
          tipo_str = "tipo: #{produto[1]['tipo']}" 
        else
          tipo_str = ""
        end
        puts "#{time.strftime('%d/%m/%Y %H:%M:%S')}\nAcessando: #{base_url}#{produto_url} #{tipo_str}"

        produto_atual = @scraper.search(base_url, produto_url, regra_preco_produto, regra_estoque_produto)
        
        #Verifica se o produto foi corretamente recuperado do Site
        if !produto_atual
          atualiza_log
          
          #Verifica se há algum erro anterior e se este já aconteceu a mais de 1 dia (24h)
          erros_acessos = @db_util.get_erros_acessos key, produto_url
          if erros_acessos.count > 0
            #Verifica se já passou 1 dia
            diff_time = Time.now - erros_acessos.first[:hora_acesso]
            if diff_time >= DAY_IN_SECS
              #Notifica que o erro está acontecendo
              @twitter.post_erro_acesso nome
              
              #Remove da tabela esse erro de acesso para reiniciar a contagem
              @db_util.delete_erros_acessos key, produto_url
            end
          end
          
          #Caso tenha acontecido algum erro atualiza o banco informando que não encontrou o site
          @db_util.atualiza_erro_acesso key, produto_url
          
          next
        end

        #Acessar banco para recuperar dados para comparação
        db_produtos = @db_util.get_produtos key, produto_url

        unless db_produtos.nil?
          begin
            aplicar_rules! rules, db_produtos, produto_atual, nome
          rescue StandardError => msg_error
            #chamar o notifier.rb para falar que a yml está errada
            if msg_error.start_with? "[ERRO]"
              @twitter.post msg_error
            else
              puts msg_error
            end
          end
        end

        # adiciona no banco o novo produto
        @db_util.add_produto key, produto_url, produto_atual[:preco], produto_atual[:estoque]
        
        # remove do banco qualquer erro de acesso a esse produto
        @db_util.delete_erros_acessos key, produto_url

        atualiza_log
      end
    end
  end
  
  def aplicar_rules! rules, produtos, produto_atual, nome
    puts "\tAplicando rules: "
    rules.each do |rule|
      metodo = rule[1].split("_")[0]
      argumento = rule[1].split("_")[1]

      if self.respond_to? metodo
	      if argumento.nil?
	        puts "\t\tRule #{metodo} sem argumento"
	      else
	        puts "\t\tRule #{metodo} com argumento #{argumento}"
	      end
        
        # verifica se a rule passou
        if send(metodo, produtos, produto_atual, argumento)
          puts "\t\t\tSim"
          #chama o notifier.rb para informar que encontrou algo no Twitter
          @twitter.post_rule_update nome, rule[1]
        else
          puts "\t\t\tNão"
        end
      else
        raise "[ERRO] A regra #{metodo} não existe! Corrija o arquivo sites.yml"
      end
    end
  end
  
  def preco produtos, produto_atual, percento
    if percento.nil?
      percento = "0"
    else
      percento = percento.sub "%", ""
    end

    preco_atual = produto_atual[:preco]
    media = 0
    
    produtos.each do |produto|
      media += produto[:preco]
    end
    media /= produtos.count
    
    percento = percento.to_f / 100
    limite = media * percento
    
    preco_atual > (media + limite) || preco_atual < (media - limite)
  end
  
  def estoque produtos, produto_atual, estoque
    if estoque.nil?
      bool = produto_atual[:estoque]
    elsif estoque == "sim"
      bool = true
    else
      bool = false
    end
    
    last_estoque_db = produtos.order(:id).last[:estoque]
    if (last_estoque_db != produto_atual[:estoque])
      produto_atual[:estoque] == bool
    else
      false
    end
  end

  def atualiza_log
    puts `echo "" >> logs/cron.log`
  end
  
  def tinyurl(url)
    tinyurl = nil
    Kernel.open( "|-", "r" ) do |f|
      if f
        tinyurl = f.read
      else
        exec "curl", "-s", "http://tinyurl.com/api-create.php?url=#{CGI.escape(url)}"
      end
    end
    tinyurl
  end
  
end

# Executa a primeira vez quando o PriceMonitr é inicializado
pm = PriceMonitr.new
pm.executar!


# aguarda retorno para cada um dos sites, caso contrário agenda uma chamada em breve
#  -- caso o site não responda passe ele pro final da fila, caso já seja o final da fila, notifique site/produto não disponível
#    -- caso nenhum produto de um site responda faça uma chamada no site para avaliar a resposta (200 ou 302 OK) (404 ou 500 abaixo) 
#  -- caso a chamada ao site esteja retornando 404 ou 500 por mais de 3 dias consequentes avisar através do notifier.rb

# ao final guardar no log report do ocorrido
