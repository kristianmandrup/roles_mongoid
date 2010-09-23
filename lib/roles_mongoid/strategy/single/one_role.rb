module RoleStrategy::Mongoid
  module OneRole
    def self.default_role_attribute
      :one_role
    end

    def self.included base
      base.extend Roles::Generic::Role::ClassMethods
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
          role_ids = Role.where(:name.in => role_names.to_strings).to_a.map(&:user_id)
          where(:_id.in => role_ids)
        rescue 
          return []
        end
      end  
    end

    module Implementation      
      # assign roles
      def roles=(*_roles) 
        _roles = get_roles(_roles)
        return nil if !_roles || _roles.empty?
                
        first_role = _roles.flatten.first
        role_relation = role_class.find_role(first_role)  
        self.send("#{role_attribute}=", role_relation)
        one_role.save
      end
      alias_method :role=, :roles=
      
      # query assigned roles
      def roles
        role = self.send(role_attribute)
        role ? [role.name.to_sym] : []
      end
      
      def roles_list
        self.roles.to_a
      end      
    end

    extend Roles::Generic::User::Configuration
    configure :num => :single, :type => :role_class    
  end  
end
