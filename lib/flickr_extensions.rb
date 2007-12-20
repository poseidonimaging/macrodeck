# Flickr.rb Extensions
# Adds some extra features to Flickr.rb.
#
# (C) 2007 Keith Gable
# License: GNU GPL v2

module Flickr::Extensions
	module Photo
		module ClassMethods
			# Returns a Photo for a SimpleXML request reply block.
			def from_request(request)
				p = Flickr::Photo.new(request["id"])
				p.instance_variable_set("@title", request["title"])
				p.instance_variable_set("@owner", request["owner"])
				p.instance_variable_set("@server", request["server"])
				return p
			end
		end
	end
end

# Extend flickr.rb now.
Flickr::Photo.class_eval { extend Flickr::Extensions::Photo::ClassMethods }
