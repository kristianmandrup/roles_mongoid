require 'spec_helper'

use_roles_strategy :embed_one_role

class User
  include Mongoid::Document  
  include Roles::Mongoid 
  
  strategy :embed_one_role, :role_class => :role, :config => :default
  role_class :role

  valid_roles_are :admin, :guest, :user
end

def api_name
  :embed_one_role
end

load 'roles_mongoid/strategy/api_examples.rb'
