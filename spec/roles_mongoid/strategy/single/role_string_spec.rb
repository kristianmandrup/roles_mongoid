require 'spec_helper'

use_roles_strategy :role_string

class User
  include Mongoid::Document  
  include Roles::Mongoid 
  
  strategy :role_string, :default

  valid_roles_are :admin, :guest, :user
end

def api_name
  :role_string
end

load 'roles_mongoid/strategy/api_examples.rb'

