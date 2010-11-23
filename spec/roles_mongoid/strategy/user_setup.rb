def default_user_setup
  @guest_user = User.create(:name => 'Guest user')  
  @guest_user.add_roles :guest      
  @guest_user.save     

  @normal_user = User.create(:name => 'Normal user')
  @normal_user.add_roles :guest, :user      
  @normal_user.save     
  
  @admin_user = User.create(:name => 'Admin user')
  @admin_user.add_roles :admin            
  @admin_user.save
end
