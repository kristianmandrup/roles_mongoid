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
        in_roles(role_name)
      end

      def in_roles(*role_names)
        begin
          where(role_attribute.in => role_names).to_a      
        rescue
          return []
        end
      end  
    end
    
    module Implementation 
      # assign roles
      def roles=(*new_roles)
        new_roles = new_roles.flatten.map{|r| r.to_s if valid_role?(r)}.compact
        if new_roles && new_roles.not.empty?
          self.send("#{role_attribute}=", new_roles.compact.uniq) 
        end
      end
      alias_method :role=, :roles=

      def add_roles(*roles_to_add)
        roles_to_add = roles_to_add.flatten.map{|r| r.to_s if valid_role?(r)}.compact
        if new_roles && new_roles.not.empty?
          self.send(role_attribute) << new_roles.compact.uniq
        end
      end

      # query assigned roles
      def roles
        self.send(role_attribute).map{|r| r.to_sym}
      end
      
      def roles_list     
        [roles].flatten
      end      
    end

    extend Roles::Generic::User::Configuration
    configure            
  end
end
