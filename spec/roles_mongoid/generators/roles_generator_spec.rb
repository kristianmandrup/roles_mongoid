require 'generator_spec_helper'
require_generator :mongoid => :roles

# root_dir = Rails3::Assist::Directory.rails_root
root_dir = File.join(Rails.application.config.root_dir, 'rails')

describe 'role strategy generator: admin_flag' do
  describe 'ORM: mongoid' do  
    use_orm :mongoid
    
    before :each do              
      setup_generator 'mongoid_roles_generator' do
        tests Mongoid::Generators::RolesGenerator
      end    
      remove_model :user    
    end

    after :each do
      # remove_model :user
    end
        
    it "should configure 'admin_flag' strategy" do            
      create_model :user do
        '# content'
      end
      with_generator do |g|   
        arguments = "User --strategy admin_flag --roles admin user"
        puts "arguments: #{arguments}"
        g.run_generator arguments.args
        root_dir.should have_model :user do |clazz|
          clazz.should include_module 'Mongoid::Document'
          clazz.should include_module 'Roles::Mongoid'
          puts "clazz: #{clazz}"        
          clazz.should have_call :valid_roles_are, :args => ':admin, :guest, :user'
          clazz.should have_call :strategy, :args => ":admin_flag"        
        end
      end
    end

    it "should configure 'one_role' strategy" do            
      create_model :user do
        '# content'
      end
      with_generator do |g|   
        arguments = "User --strategy one_role --roles admin user"
        puts "arguments: #{arguments}"
        g.run_generator arguments.args
        root_dir.should have_model :user do |clazz|
          clazz.should include_module 'Mongoid::Document'
          clazz.should include_module 'Roles::Mongoid'
          puts "clazz: #{clazz}"        
          clazz.should have_call :valid_roles_are, :args => ':admin, :guest, :user'
          clazz.should have_call :strategy, :args => ":one_role"        
        end
      end
    end
  end
end

