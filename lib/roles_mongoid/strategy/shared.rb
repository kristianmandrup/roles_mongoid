module Roles::Mongoid
  module Strategy
    module Shared
      def set_role role
        raise ArgumentError, "#set_role only takes a single role as argument, not #{role}" if role.kind_of?(Array)
        self.send("#{role_attribute}=", role)
      end
      
      def set_roles *roles
        roles = roles.flat_uniq
        roles = roles.first if self.class.role_strategy.multiplicity == :single        
        self.send("#{role_attribute}=", roles)
      end
            
      def get_role
        r = self.send(role_attribute)
      end

      def get_roles
        r = self.send(role_attribute)
      end

      def select_valid_roles *roles
        roles.flat_uniq.select{|role| valid_role? role }
        has_role_class? ? role_class.find_roles(roles).to_a.flat_uniq : roles.flat_uniq
      end           
    end
  end
end