require 'wombat'
require 'watir'

class MasterCrawler
  include Wombat::Crawler

  base_url "http://www.stylinonline.com"
  
  #TODO pegar da yml
  list_page "/hoodie-batman-joker-face-view-zip.html"
  
  #TODO pegar da yml
  name = "stylinonline"
  produto = "joker_hoodie"
  
  preco "css=div.saleprice-dec font span"
  estoque "css=div.inStock-61011"
  #TODO persiste no mongo

end
