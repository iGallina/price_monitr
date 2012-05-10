require 'rubygems'
require 'twitter'

#criado o https://twitter.com/#!/pricemonitr

Twitter.configure do |config|
  config.consumer_key = "xjIOgwyObkdaGXbWeVfNOw"
  config.consumer_secret = "6GJnsWWbOTcJv43UgEHRoD23J2luUKMQ6VPIvOtRFM"
  config.oauth_token = "568802701-sDgut7N8zKF4WxYhb0FX2hqfB78veXqe4KrdztwH"
  config.oauth_token_secret = "9YSlwTHt6qgA0EtJfZix4MgUJUe4WC9QYyAbNzxHos"
end

class TwitterNotifier
  MAX_NAME_LENGTH = 80
  
	def post message
	  time = Time.now
	  msg = "#{time.strftime('%d.%m.%y %H:%M')} - #{message}"
	  
	  puts "\t\t\t#{msg}"
		Twitter.update("#{msg}")
	end
	
	def post_rule_update produto_nome, rule
	  if (produto_nome.length > MAX_NAME_LENGTH)
	    produto_nome = produto_nome[0...MAX_NAME_LENGTH-3] + "..."
    end
    
    msg = "O produto '#{produto_nome}' atende a regra '#{rule}'."
    post msg
  end
	
end
