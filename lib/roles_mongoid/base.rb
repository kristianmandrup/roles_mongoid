module Roles::Base
  def valid_roles_are(*role_list)
    strategy_class.valid_roles = role_list.to_symbols
  end
end

module Roles
  module Mongoid  
    def self.included(base) 
      base.extend Roles::Base
      base.extend ClassMethods
      base.orm_name = :mongoid
    end

    module ClassMethods
      
      MAP = {
        :admin_flag   => "field :admin_flag, :type => Boolean",
        
        :many_roles   => "references_many :many_roles, :stored_as => :array, :class_name => 'Role'",
        :one_role     => "referenced_in :one_role, :class_name => 'Role'",

        :embed_many_roles   => "embeds_many :many_roles, :class_name => 'Role'",
        :embed_one_role     => "embeds_one :one_role, :class_name => 'Role'",

        :roles_mask   => "field :roles_mask, :type => Integer, :default => 0",
        :role_string  => "field :role_string, :type => String",
        :role_strings => "field :role_strings, :type => Array",
        :roles_string => "field :roles_string, :type => String"
      }

      def strategy name, options = {}
        strategy_name = name.to_sym
        raise ArgumentError, "Unknown role strategy #{strategy_name}" if !MAP.keys.include? strategy_name
        use_roles_strategy strategy_name

        if strategies_with_role_class.include? strategy_name
          if !options.kind_of? Symbol
            @role_class_name = get_role_class(strategy_name, options)
          else
            @role_class_name = default_role_class(strategy_name)
          end
        end
        
        if default_options?(options) && MAP[strategy_name]
          instance_eval statement(MAP[strategy_name])
        end       

        case name
        when :embed_one_role
          raise ArgumentError, "#strategy class method must take :role_class option when using an embedded role strategy" if !@role_class_name
          @role_class_name.embedded_in :user, :inverse_of => :one_role
        when :embed_many_roles
          raise ArgumentError, "#strategy class method must take :role_class option when using an embedded role strategy" if !@role_class_name
          @role_class_name.embedded_in :user, :inverse_of => :many_roles
        end

        set_role_strategy strategy_name, options
      end    

      private

      def default_options? options = {}
        return true if options == :default                           
        if options.kind_of? Hash
          return true # if options[:config] == :default || options == {} 
        end
        false
      end

      def statement code_str
        code_str.gsub /Role/, @role_class_name.to_s
      end

      def default_role_class strategy_name
        if defined? ::Role
          require "roles_mongoid/role"
          return ::Role 
        end
        raise "Default Role class not defined"
      end

      def strategies_with_role_class
        [:one_role, :embed_one_role, :many_roles,:embed_many_roles]
      end 

      def get_role_class strategy_name, options
        options[:role_class] ? options[:role_class].to_s.camelize.constantize : default_role_class(strategy_name)
      end      
    end
  end
end
