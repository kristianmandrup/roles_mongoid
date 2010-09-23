class User
  include Mongoid::Document
    include Roles::Mongoid 
  strategy :admin_flag

  valid_roles_are :admin, :guest, :user
  
end
