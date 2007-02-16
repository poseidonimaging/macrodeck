# This model is used by UserService to interact
# with users in the database.

class User < ActiveRecord::Base
    def User.checkUuid(uuid)
        !find_by_uuid(uuid).nil? rescue false
    end
    
    def raise_no_record(id)
        raise ActiveRecord::RecordNotFound, "Can't find User with UUID: " + id
    end
end