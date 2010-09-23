require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('testing')
end

Mongoid.database.collections.each do |coll|
  coll.remove
end

class User
  include Mongoid::Document
  field :name
  references_many :roles, :stored_as => :array

  def self.find_roles *ids     
    arr_ids = ids.flatten    
    all.to_a.select do |user|
      user.roles.to_a.any? do |role| 
        arr_ids.include?(role._id)
      end
    end
  end

  def self.get_roles(*ids)
    arr = ids.flatten
    criteria.in(:role_ids => arr).to_a
  end  

end

class Role
  include Mongoid::Document
  field :name
end

user = User.create(:name => 'Kristian')
user.roles.create(:name => 'guest')
user.save
# 
puts "user roles: #{User.first.roles.map(&:_id)}" 

role_id = user.roles.to_a.first._id

p role_id
p User.find_roles role_id
p User.get_roles role_id