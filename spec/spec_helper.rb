require 'rspec/core'
require 'mongoid'
require 'roles_mongoid'
                 
Mongoid.configure.master = Mongo::Connection.new.db('roles_mongoid')

module Database
  def self.teardown     
    # Mongoid.database.collections.each do |coll|
    #   coll.remove
    # end
  end
end

Mongoid.database.collections.each do |coll|
  coll.remove
end

RSpec.configure do |config|
  config.mock_with :mocha
  # config.before do
  #   Mongoid.database.collections.each do |coll|
  #     coll.remove
  #   end
  # end
end


