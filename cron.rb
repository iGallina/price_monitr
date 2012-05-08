require 'rubygems'
require 'rufus/scheduler'

scheduler = Rufus::Scheduler.start_new

scheduler.every '1h' do
  puts `ruby price_monitr.rb`
end