# Roles for Mongoid

A Mongoid implementation of [Roles Generic](http://github.com/kristianmandrup/roles_generic). 
See the Roles [wiki](http://github.com/kristianmandrup/roles_generic/wiki) for an overview of the API and how to use it.

## Role strategies

Role strategies implemented:

Inline attribute on User

* admin_flag
* roles_mask
* role_string
* role_strings

Reference Role

* many_roles
* one_role

Embedded Role

* embed_many_roles
* embed_one_role

## Install

<code>gem install roles_mongoid</code>

## Rails generators

The library comes with a Rails 3 generator that lets you populate a user model with a role strategy of your choice. 

The following role strategies are included by default. Add your own by adding extra files inside the strategy folder, one file for each role strategy is recommended.

Apply :admin_flag Role strategy to User model using default roles :admin and :guest (default)

<code>$ rails g mongoid:roles User --strategy admin_flag</code>

Apply :admin_flag Role strategy to User model using default roles and extra role :author

<code>$ rails g mongoid:roles_migration User --strategy admin_flag --roles author</code>

Apply :one_role Role strategy to User model without default roles, only with roles :user, :special and :editor

<code>$ rails g mongoid:roles_migration User --strategy one_role --roles user special editor --no-default-roles</code> 

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Kristian Mandrup. See LICENSE for details.
