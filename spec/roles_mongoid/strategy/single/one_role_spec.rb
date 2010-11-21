require 'spec_helper' 
use_roles_strategy :one_role

class User 
  include Mongoid::Document  
  include Roles::Mongoid 
  
  strategy :one_role, :default
  role_class :role
  valid_roles_are :admin, :guest   

  field :name, :type => String 
end

describe "Roles for Mongoid: :one_role strategy" do
  load "roles_mongoid/user_setup"
  load "roles_generic/rspec/api"
end

