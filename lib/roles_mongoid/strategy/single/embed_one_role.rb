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
          any_in("one_role.name" => role_names)
        rescue 
          return []
        end
      end  
    end

    module Implementation  
      include Roles::Mongoid::Strategy::Single 

      def set_role role
        raise ArgumentError, "#set_role only takes a single role as argument, not #{role}" if role.kind_of?(Array)
        self.send("create_#{role_attribute}", :name => role)
      end      

      def set_roles *roles
        roles = roles.flat_uniq
        self.send("create_#{role_attribute}", :name => roles.first)
      end

      def exchange_roles *role_names
        options = last_option role_names
        raise ArgumentError, "Must take an options hash as last argument with a :with option signifying which role(s) to replace with" if !options || !options.kind_of?(Hash)
        common = role_names.to_symbols & roles_list
        if !common.empty?
          with_roles = options[:with]
          set_role with_roles
        end
      end
      
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
      end      
    end

    extend Roles::Generic::User::Configuration
    configure :num => :single, :type => :role_class    
  end  
end
