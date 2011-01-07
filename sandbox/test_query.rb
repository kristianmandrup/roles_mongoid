require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('testing')
end

Mongoid.database.collections.each do |coll|
  coll.remove
end


class User
  include Mongoid::Document
  
  field :username, :type => String  
  field :email, :type => String

  def self.find_record(login)
    found = where(:username => login).to_a
    found = where(:email => login).to_a if found.empty?
    found
  end
  
  def self.find_record_generic(attributes)
    where(attributes).first    
  end 

  def self.find_record_alt(login)
    where("function() {return this.username == '#{login}' || this.email == '#{login}'}")
  end  
end

User.create :username => 'guest', :email => 'guest@email.com'
User.create :username => 'admin', :email => 'admin@email.com'
User.create :username => 'blip',  :email => 'guest@email.com'
User.create :username => 'blip', :email => 'guest@cool.com' 

puts User.all

puts "Found match 'blip'"

# puts User.find_record('blip').first.inspect
puts User.find_record_alt('blip').first.inspect

# puts User.find_record_generic(:username => 'blip')

puts "Found match 'guest@email.com'"

puts User.find_record('guest@email.com').first.inspect
