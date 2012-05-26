# encoding: utf-8

require 'rubygems'
require 'rufus/scheduler'
require_relative 'price_monitr'

scheduler = Rufus::Scheduler.start_new
@pm = PriceMonitr.new

scheduler.every '30m' do
  puts "*** Executando o Monitorador de Preços ***"

  time_started = Time.now
  @pm.executar!
  time_ended = Time.now

  diff = time_ended - time_started
  diff = sprintf("%.2f", diff)
  puts `echo "*** Tempo de execução: #{diff} segundos ***\n" >> logs/cron.log`
end

while true
end
