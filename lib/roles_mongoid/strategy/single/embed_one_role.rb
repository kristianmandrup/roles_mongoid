require 'roles_mongoid/strategy/single'

module RoleStrategy::Mongoid
  module EmbedOneRole
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

      def role_attribute_id
        "#{role_attribute}_id"
      end       
         
      def in_role(role_name)      
        in_any_role(role_name)
      end

      def in_any_role(*role_names)
        begin                       
          the_roles = Role.where(:name.in => role_names.to_strings).to_a 
          role_ids = the_roles.map(&:_id).map(&:to_s)
          where(:"#{role_attribute_id}".in => role_ids)
        rescue 
          return []
        end
      end  
    end

    module Implementation  
      include Roles::Mongoid::Strategy::Single 
      
      def new_role role
        role_class.find_role(extract_role role)        
      end  
      
      def new_roles *roles
        new_role roles.flatten.first
      end     
      
      def present_roles *roles
        roles.map{|role| extract_role role}
      end                 
      
      def set_empty_role
        self.send("#{role_attribute}=", nil)
      end

      def select_valid_roles *role_names
        role_names = role_names.flat_uniq.select{|role| valid_role? role }
        has_role_class? ? role_class.find_roles(role_names).to_a : role_names
      end      
    end

    extend Roles::Generic::User::Configuration
    configure :num => :single, :type => :role_class    
  end  
end
