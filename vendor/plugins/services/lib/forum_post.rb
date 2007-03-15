class ForumPost < ActiveRecord::Base
    set_table_name 'data_items'
    UUID = FORUM_POST
#    def checkUUID(uuid)
#      data_group = find_by_uuid(uuid)
#      data_group.groupingtype == FORUM_POST ? data_group : false
#    end   

end