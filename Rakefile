begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "roles_mongoid"
    gem.summary = %Q{Implementation of Roles generic API for Mongoid}
    gem.description = %Q{Makes it easy to set a role strategy on your User model in Mongoid}
    gem.email = "kmandrup@gmail.com"
    gem.homepage = "http://github.com/kristianmandrup/roles_mongoid"
    gem.authors = ["Kristian Mandrup"]
    gem.add_development_dependency "rspec", '>= 2.0.1'

    gem.add_dependency "mongoid",           '>= 2.0.0.beta.20'
    gem.add_dependency 'bson',              '>= 1.1.4'

    gem.add_dependency "sugar-high",      "~> 0.3.1"
    gem.add_dependency "require_all",     '~> 1.2.0'
    gem.add_dependency "roles_generic",   '>= 0.3.3'
    
    gem.add_dependency 'rails3_artifactor', '>= 0.3.1'
    gem.add_dependency 'logging_assist',    '>= 0.2.0'


  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

