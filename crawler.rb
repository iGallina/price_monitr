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
  
  preco "xpath=//div[@class='saleprice-dec']/font/span"
  estoque "xpath=//div[@class='outStock-61011']" # se tiver em estoque a class é 'inStock-61011'  
  #TODO persiste no mongo

end
