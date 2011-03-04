require 'rspec'
require 'mongoid'
require 'roles_mongoid'
                 
Mongoid.configure.master = Mongo::Connection.new.db('roles_mongoid')

Mongoid.database.collections.each do |coll|
  coll.remove
end

RSpec.configure do |config|
  config.mock_with :mocha
end


