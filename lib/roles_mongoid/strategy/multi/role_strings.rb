require 'roles_mongoid/strategy/multi'

module RoleStrategy::Mongoid
  module RoleStrings    
    def self.default_role_attribute
      :role_strings
    end    

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def role_attribute
        strategy_class.roles_attribute_name.to_sym
      end 

      def in_role(role_name)  
        in_any_role(role_name)
      end

      def in_any_role(*role_names)
        begin
          where(role_attribute.in => role_names).to_a      
        rescue
          return []
        end
      end  
    end
    
    module Implementation 
      include Roles::Mongoid::Strategy::Multi
      
      def new_roles *roles
        ::Set.new select_valid_roles(roles)
      end      

      def select_valid_roles *roles
        roles.flat_uniq.select{|role| valid_role? role }.map(&:to_sym)
      end                 
      
      def set_empty_roles
        self.send("#{role_attribute}=", [])
      end   

      def present_roles roles_names
        roles_names.to_a
      end
    end

    extend Roles::Generic::User::Configuration
    configure            
  end
end
