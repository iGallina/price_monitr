require 'wombat'
require 'watir'

class MasterCrawler

  #TODO pegar da yml
  name = "stylinonline"
  produto = "joker_hoodie"
  
  preco "css=div.saleprice-dec font span"
  estoque "css=div.inStock-61011"
  #TODO persiste no mongo

end
