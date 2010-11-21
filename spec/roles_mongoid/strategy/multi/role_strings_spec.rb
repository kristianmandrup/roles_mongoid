require 'spec_helper'
use_roles_strategy :role_strings

class User 
  include Mongoid::Document  
  include Roles::Mongoid
  
  strategy :role_strings, :default
  valid_roles_are :admin, :guest
  
  field :name, :type => String 
end

describe "Roles for Mongoid: :role_strings strategy" do  
  load "roles_mongoid/user_setup"
  load "roles_generic/rspec/api"
end
