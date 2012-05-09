require 'rubygems'
require 'twitter'

#criado o https://twitter.com/#!/pricemonitr

Twitter.configure do |config|
  config.consumer_key = "xjIOgwyObkdaGXbWeVfNOw"
  config.consumer_secret = "6GJnsWWbOTcJv43UgEHRoD23J2luUKMQ6VPIvOtRFM"
  config.oauth_token = "568802701-sDgut7N8zKF4WxYhb0FX2hqfB78veXqe4KrdztwH"
  config.oauth_token_secret = "9YSlwTHt6qgA0EtJfZix4MgUJUe4WC9QYyAbNzxHos"
end

class Twitter
	def post message
		Twitter.update("#{message}")
	end
end
