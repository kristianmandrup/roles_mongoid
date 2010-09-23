require 'spec_helper'
use_roles_strategy :admin_flag

class User 
  include Mongoid::Document  
  include Roles::Mongoid 
  
  strategy :admin_flag, :default
  valid_roles_are :admin, :guest  

  field :name, :type => String  
end

describe "Roles for Mongoid" do
  after :each do
    Database.teardown
  end

  before :each do
    @user = User.create(:name => 'Kristian')
    @user.roles = :guest
    @user.save     

    @admin_user = User.create(:name => 'Admin user')
    @admin_user.roles = :admin    
    @admin_user.save
  end

  describe "Admin flag strategy " do

    describe '#in_role' do
      it "should return first user maching role" do
        User.in_role(:guest).first.name.should == 'Kristian'
        User.in_role(:admin).first.name.should == 'Admin user'
      end
    end

    describe 'roles API' do
      it "should have admin user role to :admin" do
        @admin_user.role.should == :admin
        @admin_user.roles.should == [:admin]      
        @admin_user.admin?.should be_true
         
        @admin_user.class.valid_roles.should == [:admin, :guest]
        
        @admin_user.has_role?(:guest).should be_false
        
        @admin_user.has_role?(:admin).should be_true
        @admin_user.is?(:admin).should be_true
        @admin_user.has_roles?(:admin).should be_true
        @admin_user.has?(:admin).should be_true      
      end

      it "should have user role to :guest" do
        @user.roles.should == [:guest]
        @user.admin?.should be_false
      
        @user.has_role?(:guest).should be_true    
        @user.has_role?(:admin).should be_false
        @user.is?(:admin).should be_false
        
        @user.has_roles?(:guest).should be_true
        @user.has?(:admin).should be_false
      end
      
      it "should set user role to :admin using =" do
        @user.roles = :admin      
        @user.role.should == :admin           
        @user.has_role?(:admin).should be_true      
      end    
    end
  end
end

