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
  
end

db_util = DBUtil.new
produto = db_util.get_produto "alguma url"

puts produto.inspect