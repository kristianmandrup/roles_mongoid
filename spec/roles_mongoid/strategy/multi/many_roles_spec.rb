require 'spec_helper'

class Role
end

class User
  include Mongoid::Document  
  include Roles::Mongoid 
  
  strategy :many_roles
  valid_roles_are :admin, :guest, :user
end

def api_name
  :many_roles
end

load 'roles_mongoid/strategy/api_examples.rb'

