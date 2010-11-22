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

        # :inverse_of => :users
        :many_roles   => "references_many :many_roles, :stored_as => :array, :class_name => 'Role'",

        # :one_role     => "referenced_one :one_role, :class_name => 'Role'",

        :one_role     => "referenced_in :one_role, :class_name => 'Role'",

        :roles_mask   => "field :roles_mask, :type => Integer, :default => 1",
        :role_string  => "field :role_string, :type => String",
        :role_strings => "field :role_strings, :type => Array",
        :roles_string => "field :roles_string, :type => String"
      }
      
      def strategy name, options=nil
        if options == :default && MAP[name]
          puts "evaluate: #{MAP[name]}"
          instance_eval MAP[name] 
        end
        set_role_strategy name, options
      end    
    end
  end
end
