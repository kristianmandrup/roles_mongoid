module RoleStrategy::Mongoid
  module RoleString    
    def self.default_role_attribute
      :role_string
    end

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def role_attribute
        strategy_class.roles_attribute_name.to_sym
      end 

      def in_role(role_name) 
        where(role_attribute => role_name)
      end
    end

    
    module Implementation 
      def role_attribute
        strategy_class.roles_attribute_name
      end 
                  
      # assign roles
      def roles=(*roles)
        self.role = roles.select_labels.first.to_s
      end 
      
      def role= role_name
        if role_name.kind_of_label? && valid_role?(role_name)
          self.send("#{role_attribute}=", role_name.to_s) 
        end        
      end

      # query assigned roles
      def roles
        role = self.send(role_attribute)
        [role.to_sym]
      end
      alias_method :roles_list, :roles
    end

    extend Roles::Generic::User::Configuration
    configure :num => :single
  end
end


