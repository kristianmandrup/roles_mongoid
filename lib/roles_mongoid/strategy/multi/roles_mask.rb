require 'roles_mongoid/strategy/multi'

module RoleStrategy::Mongoid
  module RolesMask
    def self.default_role_attribute
      :roles_mask
    end

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def role_attribute
        strategy_class.roles_attribute_name.to_sym
      end 

      def in_role(role)     
        mask = calc_index(role.to_s)
        all.select do |user| 
          (user.send(role_attribute) & mask) > 0
        end
      end    

      def in_any_role(*roles)
        all.select do |user| 
          roles.flatten.any? do |role|
            mask = calc_index(role.to_s)
            (user.send(role_attribute) & mask) > 0
          end
        end
      end    
  
      def calc_index(r)
        2**strategy_class.valid_roles.index(r.to_sym)
      end 
    end

    module Implementation 
      include Roles::Mongoid::Strategy::Multi

      class Roles < ::Set # :nodoc:
        attr_reader :model_instance

        def initialize(sender, *roles)
          super(*roles)
          @model_instance = sender
        end

        def <<(role)
          model_instance.roles = super.to_a
          self
        end
      end

      protected

      def calc_index(r)
        2**strategy_class.valid_roles.index(r)
      end

      def get_roles 
        strategy_class::Roles.new(self, strategy_class.valid_roles.reject { |r| ((get_role || 0) & calc_index(r)).zero? })        
      end
      
      def new_roles *role_names
        role_names = role_names.flatten.map{ |r| r.to_sym } & strategy_class.valid_roles
        role_names.map { |r| calc_index(r) }.inject { |sum, bitvalue| sum + bitvalue }
      end

      def set_empty_roles
        self.send("#{role_attribute}=", 0)
      end
      
      def present_roles *role_names
        role_names.to_a.to_symbols
      end

      def set_roles *roles
        roles = roles.flat_uniq
        roles = roles.first if self.class.role_strategy.multiplicity == :single
        vrs = new_roles roles
        self.send("#{role_attribute}=", vrs)
      end

            
      # class Roles < ::Set # :nodoc:
      #   attr_reader :model_instance
      # 
      #   def initialize(sender, *roles)
      #     super(*roles)
      #     @model_instance = sender
      #   end
      # 
      #   def <<(role)
      #     model_instance.roles = super.to_a
      #     self
      #   end
      # end
      # 
      # def role_attribute
      #   strategy_class.roles_attribute_name
      # end 
      # 
      # # assign roles
      # def roles=(*roles)
      #   self.send("#{role_attribute}=", (roles.flatten.map { |r| r.to_sym } & strategy_class.valid_roles).map { |r| calc_index(r) }.inject { |sum, bitvalue| sum + bitvalue })
      # end
      # alias_method :role=, :roles=
      # 
      # # query assigned roles
      # def roles
      #   strategy_class::Roles.new(self, strategy_class.valid_roles.reject { |r| ((self.send(role_attribute) || 0) & calc_index(r)).zero? })
      # end
      # 
      # def roles_list
      #   roles.to_a
      # end        
      # 
      # protected
      # 
      # def calc_index(r)
      #   2**strategy_class.valid_roles.index(r)
      # end 
    end    
    
    extend Roles::Generic::User::Configuration
    configure            
  end
end
