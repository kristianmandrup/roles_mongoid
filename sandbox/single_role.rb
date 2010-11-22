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
  references_many :users #one_role, :class_name => 'Role'

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
  # include Blip
  field :name, :type => String  
  referenced_in :one_role, :class_name =>  'Role'
  
  # do_it   
end

user = User.create :name => 'Sandy'
user2 = User.create :name => 'Mike'
role = Role.create :name => 'Guest'
role2 = Role.create :name => 'Admin'

user.save
user2.save

user.one_role = role2 #<< [role, role2]
role.users << [user, user2]
user2.one_role = role

# role.users << user
# role.users << user2

role.save 

puts "user: #{user.inspect}"
puts "user2 #{user2.inspect}"
puts "role: #{role.inspect}"  
puts "role users: #{role.users.to_a.inspect}"  


# Role.create :name => 'guest'
# Role.create :name => 'admin'
# 
# user = User.create :name => 'Kristian'
# 
# 
# user.role.create :name => :guest
# user.save

# user.role = Role.find_role(:guest).first
# user.save



