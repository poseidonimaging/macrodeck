# This service requires DataService to work.
# It provides blogging functions that simplify
# accessing blog data.

class BlogService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.BlogService"
	@serviceName = "BlogService"	
	@serviceVersionMajor = 1
	@serviceVersionMinor = 0	
	@serviceVersionRevision = 20060630
	@serviceUUID = "e26afd5f-8aa9-47c9-804d-3fd0c333aaa4"
	
	# Returns all of the blog posts for user/group specified in
	# owner. The concept of ownership is as follows. Generally,
	# MacroDeck would be the creator of every blog, but we could
	# in theory have one made by an administrator. But, the user
	# who uses the blog will always own it. Previously, this
	# function looked for it by the creator, which would be
	# incorrect.
	def self.getBlogPosts(owner)
		blogposts = Array.new
		groupings = DataGroup.findGroupingsByOwner(DGROUP_BLOG, owner)
		groupings.each do |grouping|
			# There really should only be one grouping per user with
			# a DGROUP_BLOG datatype, since more than one would imply
			# a user has more than one blog. But this handles that
			# just in case.
			posts = DataItem.findDataByGrouping(grouping.groupingid, DTYPE_POST)
			# Append the posts found to blogposts.
			blogposts = blogposts + posts
		end
		return blogposts
	end
	
	# Returns all of the comments for blog post specified in postID.
	# The postID is retrieved from a particular post's dataid.
	def self.getBlogComments(postID)
		blogcomments = Array.new
		groupings = DataGroup.findGroupingsByParent(DGROUP_COMMENTS, postID)
		groupings.each do |grouping|
			comments = DataItem.findDataByGrouping(grouping.groupingid, DTYPE_COMMENT)
			blogcomments = blogcomments + comments
		end
		return blogcomments
	end
	
	# Creates a new blog. This should be done when a user registers.
	# *NOTE!* This method should NOT be used to create blog posts! This
	# is for creating actual _blogs_.
	def self.createBlog(title, description, creator, owner)
		group = DataGroup.new
		group.groupingtype = DGROUP_BLOG
		group.creator = creator
		group.groupingid = UUIDService.generateUUID # a fresh UUID, please :)
		group.owner = owner
		group.tags = nil
		group.parent = nil
		group.title = title
		group.description = description
		group.save
	end
	
	# Creates a new blog post within the blog specified. Blogs are specified
	# by their GroupingID.
	def self.createBlogPost(blog, postTitle, postDescription, postContent, readPermissions = nil, writePermissions = nil)
	end
end

Services.registerService(BlogService)