require 'spec_helper'

use_roles_strategy :roles_mask

class User
  include Mongoid::Document  
  include Roles::Mongoid 
  
  strategy :roles_mask
  valid_roles_are :admin, :guest, :user
end

def api_name
  :roles_mask
end

load 'roles_mongoid/strategy/api_examples.rb'



# require 'spec_helper'
# use_roles_strategy :roles_mask
# 
# class User 
#   include Mongoid::Document  
#   include Roles::Mongoid 
#   
#   strategy :roles_mask, :default
#   valid_roles_are :admin, :guest   
# 
#   field :name, :type => String 
# end
# 
# describe "Roles for Mongoid: :roles_mask strategy" do  
#   load "roles_mongoid/user_setup"
#   load "roles_generic/rspec/api"
# end
# 
