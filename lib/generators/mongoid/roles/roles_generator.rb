require 'rails3_artifactor'
require 'logging_assist'

module Mongoid 
  module Generators
    class RolesGenerator < Rails::Generators::NamedBase      
      desc "Add role strategy to a model" 

      # argument name
      
      class_option :strategy, :type => :string, :aliases => "-s", :default => 'role_string', 
                   :desc => "Role strategy to use (admin_flag, role_string, roles_string, role_strings, roles_mask, one_role, many_roles, embed_one_role, embed_many_roles)"

      class_option :logfile, :type => :string,   :default => nil,   :desc => "Logfile location"
      class_option :roles, :type => :array, :aliases => "-r", :default => [], :desc => "Valid roles"

      def apply_role_strategy
        logger.add_logfile :logfile => logfile if logfile
        logger.debug "apply_role_strategy for : #{strategy} in model #{name}"

        if !valid_strategy?
          say "Strategy #{strategy} is not currently supported, please try one of #{valid_strategies.join(', ')}", :red
        end

        if !has_model_file?(user_model_name)
          say "User model #{user_model_name} not found", :red
          return 
        end

        begin 
          insert_into_model user_model_name, :after => /include Mongoid::\w+/ do
            insertion_text
          end     

          unless read_model(:user) =~ /use_roles_strategy/
            inject_into_file model_file(:user), "use_roles_strategy :#{strategy}\n\n", :before => "class"
          end        
        rescue Exception => e
          logger.debug"Error: #{e.message}"
        end
      end 
      
      protected                  

      include Rails3::Assist::BasicLogger
      extend Rails3::Assist::UseMacro

      use_orm :mongoid

      def valid_strategy?
        valid_strategies.include? strategy.to_sym
      end

      def valid_strategies
        [:admin_flag, :one_role, :embed_one_role, :role_string, :embed_many_roles, :many_roles, :role_strings, :roles_mask]
      end

      def logfile
        options[:logfile]
      end

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
        "strategy :#{strategy}, #{strategy_option_arg}"
      end

      def strategy_option_arg
        case strategy
        when 'embed_one_role', 'embed_many_roles'
          ":role_class => :role, :config => :default"
        else
          ":default\n#{role_class_stmt}"
        end
      end

      def role_class_stmt
        "  role_class :role" if [:one_role, :many_roles].include? (strategy.to_sym)
      end

      def roles_statement
        return '' if has_valid_roles_statement?
        roles ? "valid_roles_are #{roles.join(', ')}" : ''
      end

      def has_valid_roles_statement? 
        !(read_model(user_model_name) =~ /valid_roles_are/).nil?
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