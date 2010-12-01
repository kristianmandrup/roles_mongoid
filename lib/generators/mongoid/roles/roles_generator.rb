require 'rails3_artifactor'
require 'logging_assist'

module Mongoid 
  module Generators
    class RolesGenerator < Rails::Generators::Base      
      desc "Add role strategy to a model" 

      # argument name
      
      class_option :strategy, :type => :string, :aliases => "-s", :default => 'role_string', 
                   :desc => "Role strategy to use (admin_flag, role_string, roles_string, role_strings, one_role, many_roles, roles_mask)"

      class_option :logfile, :type => :string,   :default => nil,   :desc => "Logfile location"
      class_option :roles, :type => :array, :aliases => "-r", :default => [], :desc => "Valid roles"

      def apply_role_strategy
        logger.add_logfile :logfile => logfile if logfile
        logger.debug "apply_role_strategy for : #{strategy} in model #{name}"
        insert_into_model user_model_name, :after => /include Mongoid::\w+/ do
          insertion_text
        end
      end 
      
      protected                  

      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro

      use_orm :mongoid

      def user_model_name
        name || 'User'
      end

      def orm
        :mongoid
      end

      def default_roles
        [:admin, :guest]        
      end

      def roles_to_add
        @roles_to_add ||= default_roles.concat(options[:roles]).to_symbols.uniq
      end

      def roles        
        roles_to_add.map{|r| ":#{r}" }
      end

      def role_strategy_statement 
        "strategy :#{strategy}, :default\n#{role_class_stmt}"
      end

      def role_class_stmt
        "  role_class :role" if [:one_role, :many_roles].include? (strategy.to_sym)
      end

      def roles_statement
        roles ? "valid_roles_are #{roles.join(', ')}" : ''
      end

      def insertion_text
        %Q{include Roles::#{orm.to_s.camelize} 
  #{role_strategy_statement}
  #{roles_statement}}
      end

      def strategy
        options[:strategy]                
      end
    end
  end
end