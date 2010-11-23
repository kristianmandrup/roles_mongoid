require 'spec_helper'

use_roles_strategy :role_strings

class User
  include Mongoid::Document  
  include Roles::Mongoid 
  
  strategy :role_strings, :default

  valid_roles_are :admin, :guest, :user
end

def api_name
  :role_strings
end

load 'roles_mongoid/strategy/api_examples.rb'

