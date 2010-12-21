require 'roles_mongoid/strategy/multi'

module RoleStrategy::Mongoid
  module EmbedManyRoles
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
        in_any_role(role_name)
      end

      def in_any_role(*role_names)
        begin
          any_in("many_roles.name" => role_names)
        rescue
          return []
        end
      end
    end

    module Implementation
      include Roles::Mongoid::Strategy::Multi

      def set_role role
        raise ArgumentError, "#set_role only takes a single role as argument, not #{role}" if role.kind_of?(Array)
        self.send("#{role_attribute}=", nil)
        self.send("create_#{role_attribute}").create(:name => role)
      end      

      def set_roles *roles
        roles = roles.flat_uniq
        self.send("#{role_attribute}=", nil)        
        roles.each do |role|
          self.send("#{role_attribute}").create(:name => role)
        end
      end

      def roles_diff *roles
        self.roles_list - extract_roles(roles.flat_uniq)
      end

      def remove_roles *role_names
        role_names = role_names.flat_uniq
        set_empty_roles and return if roles_diff(role_names).empty?
        roles_to_remove = select_valid_roles(role_names)       
        
        diff = roles_diff(role_names)
        set_roles(diff) 
        true
      end

      def exchange_roles *role_names
        options = last_option role_names
        raise ArgumentError, "Must take an options hash as last argument with a :with option signifying which role(s) to replace with" if !options || !options.kind_of?(Hash)
        common = role_names.to_symbols & roles_list
        if !common.empty?
          with_roles = options[:with]
          set_roles with_roles
        end
      end

      def select_valid_roles *role_names
        role_names = role_names.flat_uniq.select{|role| valid_role? role }        
      end      

      def has_roles?(*roles_names)
        compare_roles = extract_roles(roles_names.flat_uniq)
        (roles_list & compare_roles).not.empty?      
      end

      def get_roles
        self.send(role_attribute)
      end      

      def roles
        get_roles.to_a.map do |role|
          role.respond_to?(:sym) ? role.to_sym : role
        end
      end

      def roles_list
        my_roles = [roles].flat_uniq
        return [] if my_roles.empty?
        has_role_class? ? my_roles.map{|r| r.name.to_sym } : my_roles          
      end
        
      # assign multiple roles
      def roles=(*role_names)
        role_names = role_names.flat_uniq
        role_names = extract_roles(role_names)
        return nil if role_names.empty?

        vrs = select_valid_roles role_names
        set_roles(vrs)
      end

      def new_roles *role_names
        role_class.find_roles(extract_roles role_names)
      end

      def present_roles roles_names
        roles_names.to_a.map{|role| role.name.to_s.to_sym}
      end

      def set_empty_roles
        self.send("#{role_attribute}=", [])
      end
    end

    extend Roles::Generic::User::Configuration
    configure :type => :role_class
  end
end
