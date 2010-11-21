require 'spec_helper'
use_roles_strategy :admin_flag

class User 
  include Mongoid::Document  
  include Roles::Mongoid 
  
  strategy :admin_flag, :default
  valid_roles_are :admin, :guest  

  field :name, :type => String  
end

def api_name
  :admin_flag
end

load 'roles_mongoid/strategy/api_examples.rb'

# require 'spec_helper'
# use_roles_strategy :admin_flag
# 
# class User 
#   include Mongoid::Document  
#   include Roles::Mongoid 
#   
#   strategy :admin_flag, :default
#   valid_roles_are :admin, :guest  
# 
#   field :name, :type => String  
# end
# 
# describe "Roles for Mongoid: :admin_flag strategy" do
#   load "roles_mongoid/user_setup"
#   load "roles_generic/rspec/api"
# end
# 
