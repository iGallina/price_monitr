require 'twitter'

# TODO refatorar essa porra ?
Twitter.configure do |config|
  config.consumer_key = "xjIOgwyObkdaGXbWeVfNOw"
  config.consumer_secret = "6GJnsWWbOTcJv43UgEHRoD23J2luUKMQ6VPIvOtRFM"
  config.oauth_token = "568802701-sDgut7N8zKF4WxYhb0FX2hqfB78veXqe4KrdztwH"
  config.oauth_token_secret = "9YSlwTHt6qgA0EtJfZix4MgUJUe4WC9QYyAbNzxHos"
end

#criado o https://twitter.com/#!/pricemonitr
# TODO falta criar as notificações pro celular da Natasha
# E definir as regras

# testado e funcionando
Twitter.update("teste")