# This file is a stub for Rails so it loads our
# "real" library.

require "services"
require "acts_as_ferret"

class ActiveRecord::Base

  def self.checkUUID(uuid)
    case self.to_s
      when 'ForumPost': class_uuid = FORUM_POST
      when 'ForumReply': class_uuid = FORUM_REPLY
      when 'Forum': class_uuid = FORUM                        
      when 'ForumCategory': class_uuid = FORUM_CATEGORY
      when 'ForumBoard': class_uuid = FORUM_BOARD
      else return nil        
    end
    obj = find_by_uuid(uuid)
    return nil unless obj
    return obj.grouping == class_uuid ? true : false 
  end
  
end