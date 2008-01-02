# Flickr.rb Extensions
# Adds some extra features to Flickr.rb.
#
# (C) 2007 Keith Gable
# License: GNU GPL v2

module Flickr::Extensions
	module Photo
		module ClassMethods
			# Returns a Photo for a XMLSimple request reply block.
			def from_request(request)
				if request != nil && request["id"] != nil
					p = Flickr::Photo.new(request["id"])
					p.instance_variable_set("@title", request["title"])
					p.instance_variable_set("@owner", request["owner"])
					p.instance_variable_set("@server", request["server"])
					return p
				else
					return nil
				end
			end
		end
		module InstanceMethods
			def initialize(id=nil,client=Flickr.new)
				@id = id
				@client = client
			end
		end
	end
end

# Extend flickr.rb now.
Flickr::Photo.class_eval { extend Flickr::Extensions::Photo::ClassMethods }
Flickr::Photo.class_eval { include Flickr::Extensions::Photo::InstanceMethods }
