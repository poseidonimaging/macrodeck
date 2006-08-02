# This file contains all of the default UUID-to-constant mappings
# that should be present in every instance of the Services
# plugin. If you have UUIDs you wish to add for your application,
# please use local_uuids.rb.

module ServicesModule
	module DefaultUUIDs
		# Constants for data types

		DTYPE_POST		= "13569fca-5b8c-4ec3-8738-350165a37592" # A blog post.
		DTYPE_EVENT		= "1a5527bb-515b-4f69-807e-facf578e0f2d" # A calendar event.
		DTYPE_COMMENT	= "9a232c1d-55f7-4edd-8b60-e942eca82ea2" # A blog post comment.

		# Constants for data groups

		DGROUP_BLOG		= "f7ae8ebd-c49a-4c9c-8f8c-425d32e64d88" # A user/group/site's blog.
		DGROUP_CALENDAR	= "ae32a6aa-bfb2-4126-87a1-7041da0ce6e5" # A calendar.
		DGROUP_COMMENTS	= "841d7152-1a50-43c5-b53f-75437faad6a2" # A blog post's comments.

		# Default creator/owner constants
		NOBODY			= "574ecd0f-afb1-40e4-a71b-1e66622db0de"
		ANONYMOUS		= "00000000-0000-0000-0000-000000000000"
	end
end