

class StorageService < BaseService
	@serviceAuthor = "Eugene Hlyzov <ehlyzov@issart.com>"
	@serviceID = "com.macrodeck.StorageService"
	@serviceName = "StorageService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 1	
    @serviceUUID = "???"    
    
    # Creates a file (of course, folder is a file too)
    # type is a symbol, may be :file or :folder for now
    # Example: 
    #   StorageService.createFile("test.txt", :file, {:owner => ...})
    #   StorageService.createFile("eugene.storage", :folder, {:owner => ...})
    def StorageService.createFile(name, type, metadata)
    end
    
    # Adds a specify tag to the file
    # Example:
    #   StorageService.addTagToFile(some_file, 'SCORESHEET')
    def StorageService.addTagToFile(file_id, tag)
    end

    # Modifies the file metadata. Second param is a hash.
    def StorageService.modifyFileMetadata(file_id, metadata)
    end
    
    # Modifies the file metadata by specified name. 
    # This is a just proxy to modifyFileMetadata method
    def StorageService.modifyFileMetadata(file_id, name, value)
        return modifyFileMetadata(file_id,Hash[name,value])
    end

    # Renames the file
    # Example:
    #   StorageService.renameFile(some_file, "me.jpg")
    def StorageService.renameFile(file_id, file_name)
    end
    
    # Deletes the file
    def StorageService.deleteFile(file_id)
    end

    # Gets folder contents. Result is an array of hashes
    # Example:
    #   StorageService.getFolderContents(my_folder)
    #   => [
    #         {:id => 1, :name => "me.jpg", ...},
    #         {:id => 2, :name => "the_sun.jpg", ...},
    #         {:id => 3, :name => "after_the_rain.png", ...}
    #      ]
    #   
    def StorageService.getFolderContents(folder_id)
    end

    # Manages with file's quotas.
    # Quota is a hash with several params (:max_file_size, :total_size)
    # Example:
    #   StorageService.setupQuotas(my_storage, friends, {:max_file_size => "2Mb", ...})
    #   StorageService.setupQuotas(my_storage, friends, {}) # removes friends quota
    def StorageService.setupQuotas(file_id, user_or_group_id, quota)
    end
    
end
Services.registerService(StorageService)
