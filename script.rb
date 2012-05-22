#!/usr/bin/ruby1.9.1
## TODO ruby1.9.1 e ps -aux

def stop
	puts "Stopping..."
	bash = `ps au | grep cron.rb`
	bash.each_line do |line|
		pid = 0
		if line.include?("ruby1.9.1 cron.rb")
			columns = line.split(" ")
			pid = columns[1]
		end
		if(pid != 0)
			puts `kill -9 #{pid}`
		end
	end
	puts `echo "Servidor parado." >> cron.log`
end

def start
	puts "Starting..."
	puts `echo "Servidor iniciado." >> cron.log`

	bash = `ruby1.9.1 cron.rb >> cron.log &`
	puts bash
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