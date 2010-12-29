require 'spec_helper'

class Role
end

class User
  include Mongoid::Document  
  include Roles::Mongoid 
  
  strategy :one_role
  valid_roles_are :admin, :guest, :user
end

def api_name
  :one_role
end

load 'roles_mongoid/strategy/api_examples.rb'
