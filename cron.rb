require 'rubygems'
require 'rufus/scheduler'
require_relative 'price_monitr'

scheduler = Rufus::Scheduler.start_new

scheduler.every '1h' do
  puts "*** Executando o Monitorador de Precos ***"
  pm = PriceMonitr.new
  pm.executar!
end

while true
end