class <%= role_class %>
  include Mongoid::Document
  field :name, :type => String

  validates_uniqueness_of :name

  extend RoleClass::ClassMethods
end  
