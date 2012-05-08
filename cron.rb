#require 'whenever'
require 'yaml'
require_relative 'db'

class Cron
  
  def initialize
    # instancia o DBUtil
    @db_util = DBUtil.new
  end
  
  def executar!
    # le da yml quais sites a serem analisados
    @sites = YAML::load_file('sites.yml')
    
    @sites.each do |site|
      base_url = site[1]['base_url']
      regra_preco = site[1]['regra_preco']
      regra_estoque = site[1]['regra_estoque']

      produtos = site[1]['produtos']
      produtos.each do |produto|
        key = produto[0]
        produto_url = produto[1]['url']
        nome = produto[1]['nome']
        rules = produto[1]['rules']

        # acessa o site e recupera os dados
        puts "Acessando: #{base_url}#{produto_url}"
        produto_atual = {:preco => 110.0, :estoque => true}

        #Acessar banco para recuperar dados para comparação
        db_produtos = @db_util.get_produtos key, produto_url

        unless db_produtos.nil?
          puts "Aplicando rules: "
          rules.each do |rule|
            metodo = rule[1].split("_")[0]
            argumento = rule[1].split("_")[1]

            if self.respond_to? metodo
              puts "Executando rule #{metodo} com argumento #{argumento}"
              
              # se a verificacao passou
              if send(metodo, db_produtos, produto_atual, argumento)
                #chamar o notifier.rb para informar que encontrou algo
                puts "sim"
              end
              
            else
              #chamar o notifier.rb para falar que o yml está errado
              raise "[ERRO] Metodo :#{metodo} nao existe!"
            end
          end
        end

        # adiciona no banco o novo produto
        preco = 100.0
        estoque = true
        @db_util.add_produto key, produto_url, preco, estoque

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

cron = Cron.new
cron.executar!


# aguarda retorno para cada um dos sites, caso contrário agenda uma chamada em breve
#  -- caso o site não responda passe ele pro final da fila, caso já seja o final da fila, notifique site/produto não disponível
#    -- caso nenhum produto de um site responda faça uma chamada no site para avaliar a resposta (200 ou 302 OK) (404 ou 500 abaixo) 
#  -- caso a chamada ao site esteja retornando 404 ou 500 por mais de 3 dias consequentes avisar através do notifier.rb

# ao final guardar no log report do ocorrido
