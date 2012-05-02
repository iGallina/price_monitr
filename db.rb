#require 'sequel'
#Ou usar YML ?

#postgres ou mongo?

# TODO ta dando erro no yaml de parsing sei lá pq..
require 'yaml'
sites = YAML::load_file('sites.yml')
puts sites.inspect