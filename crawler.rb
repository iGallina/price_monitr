require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.run_server = false
Capybara.current_driver = :poltergeist

# delay pro JS carregar
#Capybara.default_wait_time = 5

module Scraper
  class SearchScraper
    include Capybara::DSL
	
    def search base_url, url, regra_preco, regra_estoque
      begin
      	Capybara.app_host = base_url
      	visit(url)

        #Preço
        begin
  		    preco = page.find(regra_preco).text
  		    preco.sub! ",", "."
  	    rescue Capybara::ElementNotFound
  	      preco = 0.0
  		  end
		  
  		  #Estoque
  		  if !regra_estoque.nil?
  		    begin
        	  page.find(regra_estoque).text
        	  estoque = true
      	  rescue Capybara::ElementNotFound
      	    estoque = false
  	      end
        else
          #Não valida o estoque
          estoque = true
        end

        {:preco => preco.to_f, :estoque => estoque}
        
      rescue Capybara::Poltergeist::TimeoutError
        puts "\t[ERRO] Timeout ao acessar o site #{base_url}#{url}."
        
        false
      end
    end

  end
end


# TODO remover.. só pra Debbug
#scraper = Scraper::SearchScraper.new
#scraper.search("http://www.stylinonline.com", "/hoodie-batman-joker-face-view-zip.html", "", "")