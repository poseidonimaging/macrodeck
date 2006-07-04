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
		groupings = DataService.findDataGrouping(DGROUP_BLOG, "owner", owner)
		groupings.each do |grouping|
			# There really should only be one grouping per user with
			# a DGROUP_BLOG datatype, since more than one would imply
			# a user has more than one blog. But this handles that
			# just in case.
			posts = DataItem::findDataByGrouping(grouping.groupingid, DTYPE_POST)
			# Append the posts found to blogposts.
			blogposts = blogposts + posts
		end
		return blogposts
	end
	
	# Returns all of the comments for blog post specified in postID.
	# The postID is retrieved from a particular post's dataid.
	def self.getBlogComments(postID)
		blogcomments = Array.new
		groupings = DataService.findDataGrouping(DGROUP_COMMENTS, "parent", postID)
		groupings.each do |grouping|
			comments = DataItem.findDataByGrouping(grouping.groupingid, DTYPE_COMMENT)
			blogcomments = blogcomments + comments
		end
		return blogcomments
	end
	
	# Creates a new blog. This should be done when a user registers.
	# *NOTE*! This method should NOT be used to create blog posts! This
	# is for creating actual _blogs_.
	def self.createBlog(title, description, creator, owner)
		DataService.createDataGroup(DGROUP_BLOG, nil, title, description, nil, creator, owner, nil)
	end
	
	# Creates a new blog post within the blog specified. Blogs are specified
	# by their GroupingID.
	def self.createBlogPost(blogID, creator, postTitle, postDescription, postContent, readPermissions, writePermissions)
		# The owner is retrieved from the blog itself.
		owner = DataService.getDataGroupOwner(blogID)
		postID = DataService.createDataString(DTYPE_POST, @serviceUUID, blogID, creator, owner, nil, postTitle, postDescription, postContent, readPermissions, writePermissions)
		# now create comments group
		DataService.createDataGroup(DGROUP_COMMENTS, nil, postTitle, postDescription, nil, creator, owner, postID)
	end
	
	# Creates a new comment on a blog post
	def self.createBlogComment(postID, creator, commentTitle, commentContent, readPermissions, writePermissions)
		commentsGrouping = DataService.findDataGrouping(DGROUP_COMMENTS, :parent, postID)
		owner = DataService.getDataGroupOwner(commentsGrouping)
		DataService.createDataString(DTYPE_COMMENT, @serviceUUID, commentsGrouping, creator, owner, nil, commentTitle, nil, commentContent, readPermissions, writePermissions)
	end
end

Services.registerService(BlogService)