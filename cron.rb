#require 'whenever'
require 'yaml'

# le da yml quais sites a serem peneirados
sites = YAML::load_file('sites.yml')

sites.each do |site|
  base_url = site[1]['base_url']
  regra_preco = site[1]['regra_preco']
  regra_estoque = site[1]['regra_estoque']
  
  produtos = site[1]['produtos']
  produtos.each do |produto|
    produto_url = produto[1]['url']
    nome = produto[1]['nome']
    rules = produto[1]['rules']
    
    puts "Acessando: #{base_url}#{produto_url}"
    
    #Acessar banco para recuperar dados para comparação
    
    
    puts "Rules: "
    rules.each do |rule|
      puts "#{rule[1]}"
    end
  end
end


# aguarda retorno para cada um dos sites, caso contrário agenda uma chamada em breve
#  -- caso o site não responda passe ele pro final da fila, caso já seja o final da fila, notifique site/produto não disponível
#    -- caso nenhum produto de um site responda faça uma chamada no site para avaliar a resposta (200 ou 302 OK) (404 ou 500 abaixo) 
#  -- caso a chamada ao site esteja retornando 404 ou 500 por mais de 3 dias consequentes avisar através do notifier.rb

# ao final guardar no log report do ocorrido
