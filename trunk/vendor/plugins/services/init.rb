# This file is a stub for Rails so it loads our
# "real" library.

require "services"
require "acts_as_ferret"

class ActiveRecord::Base

  def self.checkUUID(uuid)
    case self.to_s
      when 'ForumPost': 
      when 'ForumReply': 
      when 'Forum':                         
      when 'ForumCategory': 
      when 'ForumBoard': class_uuid = self::UUID          
      else return nil        
    end
    obj = find_by_uuid(uuid)
    return nil unless obj
    return obj.grouping == class_uuid ? true : false 
  end
  
end

# This is a method from Ruby Cookbook. It initializes the instance variables for us. 
class Object
  private
  def set_instance_variables(binding, *variables)
    variables.each do |var|
      instance_variable_set("@#{var}", eval(var, binding))
    end
  end
end
