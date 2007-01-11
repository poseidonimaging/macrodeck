require 'services'
require 'data_group'
require 'data_item'

class Profile < ActiveRecord::Base
    
    set_table_name "data_groups"
    attr_protected :groupingtype
    has_many :items, :class_name=>"DataItem", :foreign_key=>"grouping"

    def before_create        
        write_attribute :groupingtype, DGROUP_PROFILE
        write_attribute :groupingid, UUIDService.generateUUID
    end
    
    def groupingtype=(newtype)
        raise "groupingtype is unchangeable attribute for this class"
    end
    
    # reading accessor for groupingid attribute
    def profile_id
        read_attribute :groupingid
    end
    
    # writing accessor for groupingid attribute    
    def profile_id=(id)
        write_attribute :groupingid, id
    end
    
    # check presence of element with specific groupingid
    def Profile.exist?(profile_id)
        Profile.find_by_profile_id(profile_id)        
    end
    
    def createNewProfile(metadata)
        DataService.createDataGroup(DGROUP_PROFILE,nil,nil,metadata) 
    end

    def Profile.find_by_profile_id(profile_id)
        return Profile.find_by_groupingid(profile_id)
    end

    # small hack - we want to find Profile with only profile id not real db's id.    
    def Profile.find(*args)
        if args.first.instance_of? Fixnum
            return find_by_profile_id(args.first)
        end
        super
    end
    
    def addNewItem(type,value,metadata)
        metadata.update(
            {
                :owner => read_attribute :owner
                :grouping => profile_id
            }
        )        
        DataService.createData(DGROUP_PROFILE_ITEM,type,value,metadata)
    end
    
    def updateMetadata(name,value)
        return DataService.modifyDataGroupMetadata(profile_id,name,value)
    end
    
    private 
    # this is another small hack of AR:Base class. we just want to be sure that
    # we will operate only with real Profile objects (i.e. groupingtype is 
    # equal DGROUP_PROFILE)
    def Profile.find_every(options)
        conditions = " AND (#{sanitize_sql(options[:conditions])})" if options[:conditions]
        options.update :conditions => "#{table_name}.groupingtype = '#{DGROUP_PROFILE}'#{conditions}"
        super
    end
    
end