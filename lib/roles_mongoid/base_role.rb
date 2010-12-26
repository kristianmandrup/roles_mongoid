module Roles::Base
  def valid_roles_are(*role_list)
    strategy_class.valid_roles = role_list.to_symbols
    if role_class_name
      role_list.each do |name| 
        begin
          role_class_name.create(:name => name.to_s)
        rescue
        end
      end
    end
  end
end
