require 'rails3_artifactor'
require 'logging_assist'

module Mongoid 
  module Generators
    class RolesGenerator < Rails::Generators::Base      
      desc "Add role strategy to a Mongoid User model" 

      argument     :user_class,   :type => :string,   :default => 'User',                     :desc => "User class name"
      
      class_option :strategy,     :type => :string,   :aliases => "-s",   :default => 'role_string', 
                   :desc => "Role strategy to use (admin_flag, role_string, roles_string, role_strings, roles_mask, one_role, many_roles, embed_one_role, embed_many_roles)"

      class_option :roles,        :type => :array,    :aliases => "-r",   :default => [],     :desc => "Valid roles"
      class_option :role_class,   :type => :string,   :aliases => "-rc",  :default => 'Role', :desc => "Role class name"

      class_option :logfile,      :type => :string,   :aliases => "-l",   :default => nil,    :desc => "Logfile location"

      def apply_role_strategy
        logger.add_logfile :logfile => logfile if logfile
        logger.debug "apply_role_strategy for : #{strategy} in model #{user_class}"

        if !valid_strategy?
          say "Strategy #{strategy} is not currently supported, please try one of #{valid_strategies.join(', ')}", :red
        end

        if !has_model_file?(user_class)
          say "User model #{user_class} not found", :red
          return 
        end

        begin 
          insert_into_model user_class, :after => /include Mongoid::\w+/ do
            insertion_text
          end     
        rescue Exception => e
          logger.debug"Error: #{e.message}"
        end
        
        copy_role_class if role_class_strategy?
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

      def orm
        :mongoid
      end

      def default_roles
        [:admin, :guest]        
      end

      def copy_role_class
        logger.debug "copy_role_class: #{role_class.underscore}"
        template 'role.rb', "app/models/#{role_class.underscore}.rb"
      end

      def roles_to_add
        @roles_to_add ||= default_roles.concat(options[:roles]).to_symbols.uniq
      end

      def roles        
        roles_to_add.map{|r| ":#{r}" }
      end

      def role_strategy_statement
        "strategy :#{strategy} #{strategy_option_arg}"
      end

      def strategy_option_arg
        return ", :role_class => :#{role_class.to_s.underscore}" if role_class_strategy? && role_class.to_s != 'Role'
        ''
      end

      def role_class_strategy?
        [:one_role, :many_roles, :embed_one_role, :embed_many_roles].include? strategy.to_sym
      end

      def valid_roles_statement
        return '' if has_valid_roles_statement?
        roles ? "valid_roles_are #{roles.join(', ')}" : ''
      end

      def has_valid_roles_statement? 
        !(read_model(user_class) =~ /valid_roles_are/).nil?
      end

      def insertion_text
        %Q{include Roles::#{orm.to_s.camelize} 
  #{role_strategy_statement}
  #{valid_roles_statement}}
      end

      def role_class
        options[:role_class].classify || 'Role'
      end

      def strategy
        options[:strategy]                
      end
    end
  end
end