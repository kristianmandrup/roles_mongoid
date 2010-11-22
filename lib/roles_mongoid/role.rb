module Roles::Base
  def valid_roles_are(*role_list)
    strategy_class.valid_roles = role_list.to_symbols
    if role_class_name
      role_list.each do |name|
        role_class_name.create(:name => name.to_s)
      end
    end
  end
end

class Role
  include Mongoid::Document
  field :name, :type => String
  # references_many :users

  # references_many :users, :class_name => 'User', :stored_as => :array  

  class << self
    def find_roles(*role_names)
      where(:name.in => role_names.flatten).to_a
    end

    def find_role role_name
      raise ArgumentError, "#find_role takes a single role name as argument, not: #{role_name.inspect}" if !role_name.kind_of_label?
      res = find_roles(role_name)
      res ? res.first : res
    end
  end
end  
