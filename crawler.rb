# encoding: utf-8

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
	
    def search base_url, url, regra_preco, regra_estoque, qntd = 5
      if qntd <= 0
        return false
      end
      
      begin
      	Capybara.app_host = base_url
      	visit(url)
        
        #Preço
		    preco = page.find(regra_preco).text
		    preco.sub! ",", "."
		  
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
        
        search base_url, url, regra_preco, regra_estoque, qntd-1
      rescue Capybara::Poltergeist::JavascriptError
        puts "\t[ERRO] Javascript quebrado no site #{base_url}#{url}."
        
        search base_url, url, regra_preco, regra_estoque, qntd-1
      rescue Capybara::ElementNotFound
        puts "\t[ERRO] Página não respondendo ou Elemento não encontrado no site #{base_url}#{url}."
        
        search base_url, url, regra_preco, regra_estoque, qntd-1
      end
    end

  end
end