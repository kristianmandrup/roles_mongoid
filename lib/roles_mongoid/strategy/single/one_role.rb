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
        raise "Role class #{role_class} does not have a #find_role(role) method" if !role_class.respond_to? :find_role
        return nil if !_roles || _roles.empty?
        
        _roles = _roles.select{|role| role.kind_of?(role_class) || role.kind_of_label?}
        _roles.map! do |role| 
          case role
          when role_class
            role.name
          else
            role.to_s
          end
        end
        
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
