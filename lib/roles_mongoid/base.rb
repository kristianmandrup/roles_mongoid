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
        if (options == :default || options[:config] == :default) && MAP[name]
          instance_eval MAP[name] 
        end
        if !options.kind_of? Symbol
          role_class = options[:role_class] ? options[:role_class].to_s.camelize.constantize : (Role if defined? Role)
        end

        case name
        when :embed_one_role
          raise ArgumentError, "#strategy class method must take :role_class option when using an embedded role strategy" if !role_class
          role_class.embedded_in :user, :inverse_of => :one_role
        when :embed_many_roles
          raise ArgumentError, "#strategy class method must take :role_class option when using an embedded role strategy" if !role_class
          role_class.embedded_in :user, :inverse_of => :many_roles
        end
        
        set_role_strategy name, options
      end    
    end
  end
end
