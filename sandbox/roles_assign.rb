require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('testing')
end

Mongoid.database.collections.each do |coll|
  coll.remove
end


class Role
  include Mongoid::Document
  field :name, :type => String  

  class << self
    def find_roles(*role_names)
      where(:name.in => role_names.flatten).to_a #.map(&:_id)
    end
    alias_method :find_role, :find_roles
  end
end

module Blip 
  def self.included(base)
    base.extend ClassMethods
  end 

  module ClassMethods  
    def do_it
      instance_eval "references_many :many_roles, :stored_as => :array, :class_name => 'Role'"
    end
  end
end  

class User 
  include Mongoid::Document  
  include Blip
  field :name, :type => String  

  do_it 
  
end

Role.create :name => 'guest'
Role.create :name => 'admin'

user = User.create :name => 'Kristian'

user.many_roles << Role.find_role(:guest)
user.many_roles << Role.find_role(:admin)

puts user.many_roles.inspect

