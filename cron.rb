#require 'whenever'
require 'yaml'
require_relative 'db'

# instancia o DBUtil
db_util = DBUtil.new

# le da yml quais sites a serem peneirados
sites = YAML::load_file('sites.yml')

sites.each do |site|
  base_url = site[1]['base_url']
  regra_preco = site[1]['regra_preco']
  regra_estoque = site[1]['regra_estoque']
  
  produtos = site[1]['produtos']
  produtos.each do |produto|
    key = produto[0]
    produto_url = produto[1]['url']
    nome = produto[1]['nome']
    rules = produto[1]['rules']
    
    puts "Acessando: #{base_url}#{produto_url}"
    
    #Acessar banco para recuperar dados para comparação
    db_produtos = db_util.get_produtos key, produto_url
    
    unless db_produtos.nil?
      db_produtos.each do |db_produto|
        puts "#{db_produto}"
      end
      
      puts "Aplicando rules: "
      rules.each do |rule|
        puts "#{rule[1]}"
      end
    end
    
    # acessa o site e recupera os dados
    
    
    # adiciona no banco o novo produto
    preco = 100.0
    estoque = true
    db_util.add_produto key, produto_url, preco, estoque
    
  end
end


# aguarda retorno para cada um dos sites, caso contrário agenda uma chamada em breve
#  -- caso o site não responda passe ele pro final da fila, caso já seja o final da fila, notifique site/produto não disponível
#    -- caso nenhum produto de um site responda faça uma chamada no site para avaliar a resposta (200 ou 302 OK) (404 ou 500 abaixo) 
#  -- caso a chamada ao site esteja retornando 404 ou 500 por mais de 3 dias consequentes avisar através do notifier.rb

# ao final guardar no log report do ocorrido
