require 'roles_mongoid/base_role'

class Role
  include Mongoid::Document
  field :name, :type => String

  validates_uniqueness_of :name

  class << self
    def find_roles(*role_names)
      where(:name.in => role_names.flatten).to_a
    end

    def find_role role_name
      raise ArgumentError, "#find_role takes a single role name as argument, not: #{role_name.inspect}" if !role_name.kind_of_label?
      res = find_roles(role_name)
      res ? res.first : res
    end
  end
end  
