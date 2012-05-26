#!/usr/bin/ruby1.9.1
## TODO ruby1.9.1 e ps -aux

RUBY_BIN = "ruby1.9.1"
#RUBY_BIN = "ruby"

def stop
	puts "Stopping..."

	bash = `ps au | grep cron.rb`
	bash.each_line do |line|
		pid = 0
		if line.include?("#{RUBY_BIN} cron.rb")
			columns = line.split(" ")
			pid = columns[1]
		end
		if(pid != 0)
			puts `kill -9 #{pid}`
		end
	end
	puts `echo "Servidor parado." >> logs/cron.log`

	puts "Stopped."
end

def start
	puts "Starting..."

	puts `echo "Servidor iniciado." >> logs/cron.log`

	bash = `#{RUBY_BIN} cron.rb >> logs/cron.log &`
	puts bash

	puts "Started."
end

def restart
	puts "Restarting..."
	stop
	start
end

cmd = ARGV[0]
if cmd.nil? || (cmd != "stop" && cmd != "start" && cmd != "restart")
	puts "Usage:\n\tPara iniciar utilize o parametro 'start'\n\tPara encerrar utilize o parametro 'stop'\n\tPara reiniciar utilize o parametro 'restart'"
	exit
end

send cmd
