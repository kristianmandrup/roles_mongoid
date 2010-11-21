module Roles::Mongoid
  module Strategy
    module Shared
      def set_role role
        vr = new_role(role)
        # self.send("#{role_attribute}=", vr)
        update_attributes(role_attribute => vr)
      end
      alias_method :set_roles, :set_role

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