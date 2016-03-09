require 'pp'
require 'bundler/setup'
require 'pry'
require 'pry-byebug'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'attributor/flatpack'

class SampleConfig < Attributor::Flatpack::Config
  keys do
    key :rack_env, String
    key :database do
      key :host, String
      key :username, String
      key :password, String
    end
    key :web do
      key :maxconn, Integer
      key :workers, Integer
    end
    key :world_domination, Attributor::Boolean, default: true
  end
end

# a sample ENV
env = {
  'RACK_ENV' => 'sekrit-lair',
  'DATABASE_HOST' => 'postgres://localhost/operation_doomsday',
  'DATABASE_USERNAME' => 'postgres',
  'DATABASE_PASSWORD' => '123',
  'WEB' => JSON.dump(maxconn: 10, workers: 1000)
}

config = SampleConfig.load(env)
puts "errors: #{config.validate}"
# => errors: []

puts config.pretty_print
# =>
#   rack_env="sekrit-lair"
#   database.host="postgres://localhost/operation_doomsday"
#   database.username="postgres"
#   database.password="123"
#   web.maxconn=10
#   web.workers=1000
#   world_domination=true

pp config.dump
# =>
# {:rack_env=>"sekrit-lair",
#  :database=>
#    {:host=>"postgres://localhost/operation_doomsday",
#     :username=>"postgres",
#     :password=>"123"},
#  :web=>{:maxconn=>10, :workers=>1000},
#  :world_domination=>true}
