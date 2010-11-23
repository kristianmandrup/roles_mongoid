require 'spec_helper'

use_roles_strategy :many_roles

class User
  include Mongoid::Document  
  include Roles::Mongoid 
  
  strategy :many_roles, :default
  role_class :role

  valid_roles_are :admin, :guest, :user
end

def api_name
  :many_roles
end

load 'roles_mongoid/strategy/api_examples.rb'

# 
# require 'spec_helper' 
# use_roles_strategy :many_roles
# 
# class User 
#   include Mongoid::Document  
#   include Roles::Mongoid 
#   
#   strategy :many_roles, :default
#   role_class :role
#   valid_roles_are :admin, :guest   
# 
#   field :name, :type => String 
# end
# 
# describe "Roles for Mongoid: :many_roles strategy" do
#   load "roles_mongoid/user_setup"
#   load "roles_generic/rspec/api"
# end
# 
