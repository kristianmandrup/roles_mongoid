require 'roles_mongoid/strategy/shared'

class Symbol
  def admin?
    self == :admin
  end
end

module Roles::Mongoid
  module Strategy
    module Single
      include Shared            
      # assigns first valid role from list of roles
      def add_roles *role_names
        new_roles = select_valid_roles(role_names) 
        new_role = new_roles.first if !new_roles.empty?
        set_role new_role
      end

      # should remove the current single role (set = nil) 
      # only if it is contained in the list of roles to be removed
      def remove_roles *role_names
        roles = role_names.flat_uniq
        set_empty_role if roles_diff(roles).empty?
        true
      end 
      
      def roles_list
        raise 'the method #roles should be present' if !respond_to? :roles
        present_roles(roles)
      end            
    end
  end
end