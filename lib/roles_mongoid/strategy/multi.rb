require 'roles_mongoid/strategy/shared'

module Roles::Mongoid
  module Strategy
    module Multi     
      # assign multiple roles
      def roles=(*role_names)
        extracted_roles = extract_roles(role_names)
        return nil if extracted_roles.empty?
        set_roles(select_valid_roles extracted_roles)
      end      
      
      def add_roles *roles
        new_roles = select_valid_roles(roles)
        if !new_roles.empty?
          self.roles = self.roles + new_roles
        end
      end      
      
      # should remove the current single role (set = nil) 
      # only if it is contained in the list of roles to be removed
      def remove_roles *role_names
        role_names = role_names.flat_uniq
        set_empty_roles and return if roles_diff(role_names).empty?
        roles_to_remove = select_valid_roles(role_names)
        diff = roles_diff(role_names)
        diff = role_class.find_roles(diff).to_a if self.class.role_strategy.type == :complex
        set_roles(diff) 
        true
      end

      # query assigned roles
      def roles
        get_roles.to_a.map do |role|
          role.respond_to?(:sym) ? role.to_sym : role
        end
      end

      def roles_list
        my_roles = [roles].flat_uniq
        return [] if my_roles.empty?
        has_role_class? ? my_roles.map{|r| r.name.to_sym } : my_roles          
      end
      
      protected

      def set_roles *roles
        roles = roles.flat_uniq
        roles = roles.first if self.class.role_strategy.multiplicity == :single        
        # self.send("#{role_attribute}").send(:<<, roles)        
        self.send("#{role_attribute}=", roles)        
      end

      def get_roles
        self.send(role_attribute)
      end      
    end
  end
end