# This service requires DataService to work.
# It provides blogging functions that simplify
# accessing blog data.

class BlogService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.BlogService"
	@serviceName = "BlogService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 2	
	@serviceVersionRevision = 20060626
	@serviceUUID = "e26afd5f-8aa9-47c9-804d-3fd0c333aaa4"
	
	# Returns all of the blog posts for user/group specified in
	# owner. The concept of ownership is as follows. Generally,
	# MacroDeck would be the creator of every blog, but we could
	# in theory have one made by an administrator. But, the user
	# who uses the blog will always own it. Previously, this
	# function looked for it by the creator, which would be
	# incorrect.
	def self.getBlogPosts(owner)
		blog = DataService.findDataGrouping(DGROUP_BLOG, :owner, owner, :first)
		blogposts = DataService.getDataGroupItems(blog.groupingid, DTYPE_POST)
		return blogposts
	end
	
	# Returns all of the comments for blog post specified in postID.
	# The postID is retrieved from a particular post's dataid.
	# Returns a hash that looks like this:
	#
	#  { :content => "Comment Content", :user => "UUID", :username => "Username if anonymous", :loggedin => true }
	#
	def self.getBlogComments(postID)
		post = DataService.findDataGrouping(DGROUP_COMMENTS, :parent, postID, :first)
		cgroups = DataService.getDataGroupItems(post.groupingid, DTYPE_COMMENT, :asc)
		comments = Array.new
		cgroups.each do |cgroup|
			if cgroup.objectdata != nil
				cxtrameta = YAML::load(cgroup.objectdata)
				comment = { :content => cgroup.stringdata, :user => ANONYMOUS, :username => cxtrameta[:username], :loggedin => false }
			else
				comment = { :content => cgroup.stringdata, :user => cgroup.creator, :loggedin => true }
			end
			comments << comment
		end
		return comments
	end
	
	# Creates a new blog. This should be done when a user registers.
	# *NOTE*! This method should NOT be used to create blog posts! This
	# is for creating actual _blogs_.
	def self.createBlog(title, description, creator, owner)
		DataService.createDataGroup(DGROUP_BLOG, nil, title, description, nil, creator, owner, nil)
	end
	
	# Creates a new blog post within the blog specified. Blogs are specified
	# by their GroupingID.
	#
	# FIXME: Make this method's signature more sane.
	def self.createBlogPost(blogID, creator, postTitle, postDescription, postContent, readPermissions, writePermissions)
		# The owner is retrieved from the blog itself.
		blog_meta = DataService.getDataGroupMetadata(blogID)
		owner = blog_meta[:owner]
		postID = DataService.createData(DTYPE_POST, :string, postContent, { :creatorapp => @serviceUUID, :creator => creator, :grouping => blogID, :owner => owner, :title => postTitle, :description => postDescription })
		# now create comments group
		commentsID = DataService.createDataGroup(DGROUP_COMMENTS, nil, postTitle, postDescription, nil, creator, owner, postID)
		read_perms = DataService.getPermissions(postID, :read)
		write_perms = DataService.getPermissions(postID, :write)
		DataService.setDefaultPermissions(commentsID, :read, read_perms)
		DataService.setDefaultPermissions(commentsID, :write, write_perms)
	end
	
	# Edits a post based on its postID.
	def self.editBlogPost(postID, postTitle, postDescription, postContent, readPermissions, writePermissions)
		if DataService.doesDataItemExist?(postID)
			DataService.modifyDataItem(postID, :string, postContent)
			DataService.modifyDataItemMetadata(postID, :title, postTitle)
			DataService.modifyDataItemMetadata(postID, :description, postDescription)
			# modify the comments grouping
			comments = DataService.findDataGrouping(DGROUP_COMMENTS, :parent, postID, :first)
			DataService.modifyDataGroupMetadata(comments.groupingid, :title, postTitle)
			DataService.modifyDataGroupMetadata(comments.groupingid, :description, postDescription)
			return true
		else
			return false
		end
	end
	
	# Returns a blog post by its dataID
	def self.getBlogPost(postID)
		return DataService.getData(postID, :string)
	end
	
	# Deletes a blog post by its dataID
	def self.deleteBlogPost(postID)
		DataService.deleteDataItem(postID)
		comments = DataService.findDataGrouping(DGROUP_COMMENTS, :parent, postID, :first)
		DataService.deleteDataGroup(comments.groupingid)
	end
	
	# Creates a new comment on a blog post
	#
	# FIXME: This function's signature needs to be changed to be more sane.
	def self.createBlogComment(postID, creator, username, commentContent)
		commentsGrouping = DataService.findDataGrouping(DGROUP_COMMENTS, :parent, postID, :first)
		post_meta = DataService.getDataGroupMetadata(commentsGrouping.groupingid)
		owner = post_meta[:owner]
		if creator == ANONYMOUS
			commentid = DataService.createData(DTYPE_COMMENT, :string, commentContent, { :creatorapp => @serviceUUID, :grouping => commentsGrouping.groupingid, :creator => creator, :owner => owner })
			# add the extra meta stuff
			DataService.modifyDataItem(commentid, :object, { :username => username, :user => nil, :loggedin => false })
		else
			DataService.createData(DTYPE_COMMENT, :string, commentContent, { :creatorapp => @serviceUUID, :grouping => commentsGrouping.groupingid, :creator => creator, :owner => owner })
		end
	end
	
	# Returns a hash of the blog's metadata; see DataService.getGroupMetadata.
	# +blogID+ is the groupingID of the blog
	def self.getBlogMetadata(blogID)
		return DataService.getDataGroupMetadata(blogID)
	end
	
	# Returns a hash of the post's metadata; see DataService.getItemMetadata.
	def self.getPostMetadata(postID)
		return DataService.getDataItemMetadata(postID)
	end
	
	# Returns the UUID of the blog of a user/group. If for some reason a user
	# has more than one blog, it'll return the first blog in the database. This
	# should not happen, and therefore we don't care.
	def self.getBlogUUID(userOrGroupUUID)
		blog = DataService.findDataGrouping(DGROUP_BLOG, :owner, userOrGroupUUID, :first)
		if blog != nil
			return blog.groupingid
		else
			return nil
		end
	end
	
	def self.getCommentsUUID(postID)
		post = DataService.findDataGrouping(DGROUP_COMMENTS, :parent, postID, :first)
		return post.groupingid
	end	
end

Services.registerService(BlogService)