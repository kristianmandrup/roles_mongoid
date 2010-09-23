require 'sugar-high/module'

module Roles
  modules :mongoid do
    nested_modules :user, :role
  end
  modules :base, :strategy
end   

module RoleStrategy
  modules :mongoid
end