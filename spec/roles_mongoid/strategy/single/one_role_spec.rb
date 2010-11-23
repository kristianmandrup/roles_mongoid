require 'spec_helper'

use_roles_strategy :one_role

class User
  include Mongoid::Document  
  include Roles::Mongoid 
  
  strategy :one_role, :default
  role_class :role

  valid_roles_are :admin, :guest, :user
end

def api_name
  :one_role
end

load 'roles_mongoid/strategy/api_examples.rb'
