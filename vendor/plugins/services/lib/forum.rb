class Forum < ActiveRecord::Base
    set_table_name 'data_groups'
    
    def checkUUID(uuid)
      data_group = find_by_uuid(uuid)
      data_group.groupingtype == FORUM ? data_group : false
    end    
end