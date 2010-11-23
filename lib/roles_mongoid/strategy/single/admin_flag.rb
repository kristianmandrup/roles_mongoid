require 'roles_mongoid/strategy/single'

module RoleStrategy::Mongoid
  module AdminFlag    
    def self.default_role_attribute
      :admin_flag
    end

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods 
      def role_attribute
        strategy_class.roles_attribute_name.to_sym
      end
           
      def in_role(role_name) 
        case role_name.downcase.to_sym
        when :admin
          where(role_attribute => true)
        else
          where(role_attribute => false)
        end          
      end
    end

    module Implementation
      include Roles::Mongoid::Strategy::Single

      def new_role role
        role = role.kind_of?(Array) ? role.flatten.first : role
        role.admin?
      end
      
      def get_role
        self.send(role_attribute) ? strategy_class.admin_role_key : strategy_class.default_role_key
      end 
      
      def present_roles *roles
        roles = roles.flat_uniq
        roles.map{|role| role ? :admin : :guest}
      end   
      
      def set_empty_role
        self.send("#{role_attribute}=", false)
      end      


    end # Implementation
    
    extend Roles::Generic::User::Configuration
    configure :num => :single
  end   
end
