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
	
    def search(base_url, url, regra_preco, regra_estoque)
    	Capybara.app_host = base_url
    	visit(url)

    	# Funciona
    	#puts page.find('div.saleprice-dec font span').text

    	# Não funciona (algum pau na String)
		@preco = page.find(regra_preco).text
    	
    	#@estoque = page.find(regra_estoque).text
    end

  end
end