require 'rubygems'
require 'yaml'
require_relative 'db'
require_relative 'crawler'

class PriceMonitr
  
  def initialize
    # instancia o DBUtil
    @db_util = DBUtil.new
  end
  
  def executar!
    # le da yml quais sites a serem analisados
    @sites = YAML::load_file('sites.yml')
    
    @sites.each do |site|
      base_url = site[1][:base_url]
      regra_preco = site[1][:regra_preco]
      regra_estoque = site[1][:regra_estoque]

      produtos = site[1]['produtos']
      produtos.each do |produto|
        key = produto[0]
        produto_url = produto[1]['url']
        nome = produto[1][:nome]
        rules = produto[1]['rules']

        # acessa o site e recupera os dados
        puts "Acessando: #{base_url}#{produto_url}"


        scraper = Scraper::SearchScraper.new
        scraper.search(base_url, produto_url, regra_preco, regra_estoque)

        produto_atual = {:preco => scraper.preco, :estoque => scraper.estoque}

        #Acessar banco para recuperar dados para comparação
        db_produtos = @db_util.get_produtos key, produto_url

        unless db_produtos.nil?        
          aplicar_rules! rules, db_produtos, produto_atual
        end

        # adiciona no banco o novo produto
        @db_util.add_produto key, produto_url, produto_atual[:preco], produto_atual[:estoque]
      end
    end
  end
  
  def aplicar_rules! rules, produtos, produto_atual
    puts "Aplicando rules: "
    rules.each do |rule|
      metodo = rule[1].split("_")[0]
      argumento = rule[1].split("_")[1]

      if self.respond_to? metodo
        puts "Executando rule #{metodo} com argumento #{argumento}"
        
        # verifica se a rule passou
        if send(metodo, produtos, produto_atual, argumento)
          #chamar o notifier.rb para informar que encontrou algo
          twitter = Twitter.new
          #TODO finalizar o tweet bonitinho p/ envio
          twitter.post('Rule Passou!')
          puts "sim"
        end
        
      else
        #chamar o notifier.rb para falar que o yml está errado
        raise "[ERRO] Metodo :#{metodo} nao existe!"
      end
    end
  end
  
  def preco produtos, produto_atual, percento
    percento = percento.sub "%", ""
    preco_atual = produto_atual[:preco]
    media = 0
    
    produtos.each do |produto|
      media += produto[:preco]
    end
    media /= produtos.count
    
    percento = percento.to_f / 100
    limite = media * percento
    
    preco_atual >= (media + limite) || preco_atual <= (media - limite)
  end
  
  def estoque produtos, produto_atual, estoque
    if estoque == "sim"
      bool = true
    else
      bool = false
    end
    
    produto_atual[:estoque] == bool
  end
  
end

pm = PriceMonitr.new
pm.executar!


# aguarda retorno para cada um dos sites, caso contrário agenda uma chamada em breve
#  -- caso o site não responda passe ele pro final da fila, caso já seja o final da fila, notifique site/produto não disponível
#    -- caso nenhum produto de um site responda faça uma chamada no site para avaliar a resposta (200 ou 302 OK) (404 ou 500 abaixo) 
#  -- caso a chamada ao site esteja retornando 404 ou 500 por mais de 3 dias consequentes avisar através do notifier.rb

# ao final guardar no log report do ocorrido
