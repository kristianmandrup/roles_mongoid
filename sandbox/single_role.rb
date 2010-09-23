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
  referenced_in :user  

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
      instance_eval "references_one :role" # :class_name => 'Role'
    end
  end
end  

class User 
  include Mongoid::Document  
  include Blip
  field :name, :type => String  
  references_one :role
  # do_it 
  
end

user = User.create
role = Role.create 

puts "role: #{role.inspect}"
user.role = role

user.save

# Role.create :name => 'guest'
# Role.create :name => 'admin'
# 
# user = User.create :name => 'Kristian'
# 
# puts user.inspect
# 
# user.role.create :name => :guest
# user.save

# user.role = Role.find_role(:guest).first
# user.save

puts user.role.inspect

