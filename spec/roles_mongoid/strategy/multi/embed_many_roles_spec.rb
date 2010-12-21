require 'spec_helper'

use_roles_strategy :embed_many_roles

class User
  include Mongoid::Document  
  include Roles::Mongoid 
  
  strategy :embed_many_roles, :role_class => :role, :config => :default

  valid_roles_are :admin, :guest, :user
end

def api_name
  :embed_many_roles
end

load 'roles_mongoid/strategy/api_examples.rb'
