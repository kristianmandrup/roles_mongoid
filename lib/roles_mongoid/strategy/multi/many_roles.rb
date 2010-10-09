module RoleStrategy::Mongoid
  module ManyRoles
    def self.default_role_attribute
      :many_roles
    end

    def self.included base
      base.extend Roles::Generic::Role::ClassMethods
      base.extend ClassMethods
    end

    module ClassMethods  
      def role_attribute
        "#{strategy_class.roles_attribute_name.to_s.singularize}_ids".to_sym
      end       
        
      def in_role(role_name)  
        in_roles(role_name)
      end

      def in_roles(*role_names)
        begin           
          role_ids = Role.where(:name.in => role_names.to_strings).to_a.map(&:_id)
          criteria.in(role_attribute => role_ids).to_a      
        rescue
          return []
        end
      end  
    end
    
    module Implementation
      def role_attribute
        strategy_class.roles_attribute_name
      end 
      
      # assign roles
      def roles=(*_roles) 
        _roles = get_roles(_roles)
        return nil if roles.none?                
        
        role_relations = role_class.find_roles(_roles) 
        self.send("#{role_attribute}=", role_relations)
        save
      end

      def add_roles(*roles)  
        raise "Role class #{role_class} does not have a #find_role(role) method" if !role_class.respond_to? :find_role
        role_relations = role_class.find_roles(*roles)
        self.send(role_attribute) << role_relations
        save
      end

      # query assigned roles                           
      def roles
        self.send(role_attribute)
      end

      def roles_list     
        [roles].flatten.map{|r| r.name }.compact.to_symbols
      end
    end 
    
    extend Roles::Generic::User::Configuration
    configure :type => :role_class    
  end
end

