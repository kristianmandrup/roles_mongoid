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
          role_ids = Role.where(:name.in => role_names.to_strings).to_a.map(&:_id)
          where(:"#{role_attribute}".in => role_ids).to_a
        rescue
          return []
        end
      end
    end

    module Implementation
      include Roles::Mongoid::Strategy::Multi

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
        valids = role_class.find_roles(role_names).to_a
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
