require 'sequel'
require 'sqlite3'

# connect to an in-memory database
DB = Sequel.sqlite

# create an items table
DB.create_table :produtos do
  primary_key :id
  String :url
  Float :preco
  Boolean :estoque
end

# create a dataset from the items table
produtos = DB[:produtos]


# populate the table
produtos.insert(:url => 'alguma url', :preco => 100, :estoque => true)


# print out the number of records
puts "Produto count: #{produtos.count}"

puts "Produto url: #{produtos.select(:url).first}"

# print out the average price
#puts "Produto #{Produtos.first}"