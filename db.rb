require 'rubygems'
require 'sequel'
require 'sqlite3'

class DBUtil
  
  MAX_ROWS = 3
  
  def initialize
    # conecta ao banco de dados SQLite3
    @DB = Sequel.connect('sqlite://database/produtos.db')
    
    # cria a tebale de produtos apenas se ela não existir
    @DB.create_table? :produtos do
      primary_key :id
      String :key
      String :url
      Float :preco
      Boolean :estoque
    end
    
    @produtos = @DB[:produtos]
  end
  
  def get_produtos key, url
    @produtos.filter :key => key, :url => url
  end
  
  def add_produto key, url, preco, estoque
    if get_produtos(key, url).count >= MAX_ROWS
      @produtos.filter(:key => key, :url => url, :id => @produtos.min(:id)).delete
    end
    @produtos.insert(:key => key, :url => url, :preco => preco, :estoque => estoque)
  end
  
end