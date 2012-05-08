require 'sequel'
require 'sqlite3'

class DBUtil
  
  def initialize
    # conecta ao banco de dados SQLite3
    @DB = Sequel.connect('sqlite://database/produtos.db')
    
    # cria a tebale de produtos apenas se ela não existir
    @DB.create_table? :produtos do
      primary_key :id
      String :url
      Float :preco
      Boolean :estoque
    end
  end
  
  def get_produto url
    produtos = @DB[:produtos]
    produtos[:url => url]
  end
  
  def add_produto url, preco, estoque
    produtos = @DB[:produtos]
    produtos.insert(:url => url, :preco => preco, :estoque => estoque)
  end
  
end

db_util = DBUtil.new

db_util.add_produto("url1", 10.0, true) if db_util.get_produto("url1").nil?

produto = db_util.get_produto "url1"
puts produto.inspect