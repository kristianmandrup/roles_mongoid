def default_user_setup
  @user = User.create(:name => 'Guest user')
  @user.add_roles :guest      
  @user.save     

  @user = User.create(:name => 'Normal user')
  @user.roles = :guest, :user      
  @user.save     

  @admin_user = User.create(:name => 'Admin user')
  @admin_user.roles = :admin            
  @admin_user.save
end
