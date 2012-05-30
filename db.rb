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
    
    # cria a tebale de registro dos erros de acesso apenas se ela não existir
    @DB.create_table? :erros_acessos do
      primary_key :id
      String :key_produto
      String :url_produto
      Time :hora_acesso
    end
    
    @produtos = @DB[:produtos]
    @erros_acessos = @DB[:erros_acessos]
  end
  
  def get_produtos key, url
    @produtos.filter :key => key, :url => url
  end
  
  def add_produto key, url, preco, estoque
    produtos = get_produtos(key, url)
    if produtos.count >= MAX_ROWS
      @produtos.filter(:id => produtos.order(:id).first[:id]).delete
    end
    @produtos.insert :key => key, :url => url, :preco => preco, :estoque => estoque
  end
  
  def get_erros_acessos key_produto, url_produto
    @erros_acessos.filter :key_produto => key_produto, :url_produto => url_produto
  end
  
  def atualiza_erro_acesso key_produto, url_produto
    erros_acessos = get_erros_acessos(key_produto, url_produto)
    
    #Apenas cria um registro se não existir o inicial
    if erros_acessos.count <= 0
      @erros_acessos.insert :key_produto => key_produto, :url_produto => url_produto, :hora_acesso => Time.now
    end
  end
  
  def delete_erros_acessos key_produto, url_produto
    @erros_acessos.filter(:key_produto => key_produto, :url_produto => url_produto).delete
  end
  
end