require 'whenever'
require_relative "master_crawler.rb"

# le da yml quais sites a serem peneirados

# chama o crawler passando os parâmetros para cada um dos sites
test_crawler = MasterCrawler.new
a = test_crawler.crawl

# aguarda retorno para cada um dos sites, caso contrário agenda uma chamada em breve
#  -- caso o site não responda passe ele pro final da fila, caso já seja o final da fila, notifique site/produto não disponível
#    -- caso nenhum produto de um site responda faça uma chamada no site para avaliar a resposta (200 ou 302 OK) (404 ou 500 abaixo) 
#  -- caso a chamada ao site esteja retornando 404 ou 500 por mais de 3 dias consequentes avisar através do notifier.rb

# ao final guardar no log report do ocorrido
