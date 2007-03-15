class ForumService < BaseService
  	@serviceAuthor = "Eugene Hlyzov <ehlyzov@issart.com>"
	@serviceID = "com.macrodeck.ForumService"
	@serviceName = "ForumService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 1	
    @serviceUUID = "110920b4-c110-4f54-8b86-fdda9daf08c7"
    
  def ForumService.createBoard(metadata)
    obj = ForumBoard.new do
      groupingid = UUIDService.generateUUID
      groupingtype = FORUM_BOARD
    end
    
  end
  def ForumService.updateBoardMetadata(board_uuid,metadata)
  end
  def ForumService.deleteBoard(board_uuid)
  end  
  
  def ForumService.createCategory(board_uuid,metadata)
  end
  def ForumService.updateCategoryMetadata(category_uuid,metadata)
  end
  def ForumService.deleteCategory(category_uuid)
  end

  
  def ForumService.createForum(category_uuid,metadata)
  end
  def ForumService.deleteForum(forum_uuid)
  end
  def ForumService.updateForumMetadata(forum_uuid,metadata)
  end
  
  # Create a new post in the given forum
  # +forum_uuid+:: forum where a post shoul be created
  # +msg+:: post's message
  # +metadata+:: hash of post's metadata
  # === Example
  # ForumService.createPost(@crazy_forum_uuid, 'I need few nuts.. khe..khe',{:author=>"Joe White", :title=>"I am a squirrel!" }
  def ForumService.createPost(forum_uuid,msg,metadata)     
      forum = Forum.checkUUID(forum_uuid)
      return nil unless forum           
      post = ForumPost.new do              
          owner = forum.uuid
          grouping = UUIDService.generateUUID
          stringdata = msg
          dataid = UUIDService.generateUUID
          datatype = FORUM_POST
          update_attributes(metadata)
          datacreator = @serviceUUID unless post.datacreator
      end
      post.save ? dataid : nil                 
  end
  
  # Deletes a post and all its replies (!)
  def ForumService.deletePost(post_uuid)
      post = ForumPost.checkUUID(post_uuid)
      post ? post.destroy : nil
  end
  
  # Get post by given uuid
  def ForumService.getPost(post_uuid)
      post = ForumPost.checkUUID(post_uuid)
      post ? post : nil
  end
  
  # Updates post by given uuid. 
  # +values+:: hash of updated values
  # == Example
  # ForumService.getPost(post_uuid,{:msg=>"hi Jo!"})
  def ForumService.updatePost(post_uuid,values)
      post = Post.find_by_uuid(post_uuid)
      post ? post.update_attributes(values) : nil          
  end
  
  # returns last post's reply
  def ForumService.getLastReply(post_uuid)
    post = ForumPost.checkUUID(post_uuid)
    return nil unless post    
    replys = post.replys    
    return nil if replys.empty?
    return replys[0].uuid
  end
  
  # returns true if post had been changed since given date
  def ForumService.isPostChanged?(post_uuid, since=nil)    
    post = ForumPost.checkUUID(post_uuid)
    return nil unless post    
    replys = post.replys    
    return false if replys.empty? 
    return true if since.nil?        
    return (replys[0].date > since)
  end
  

  # reply's methods' meaning are very similar to corresponding post's methods  
  
  def ForumService.createReply(post_uuid,msg,metadata)
      post = ForumPost.checkUUID(forum_uuid)
      return nil unless post           
      reply = ForumReply.new do              
          owner = post.uuid
          grouping = post.grouping
          stringdata = msg
          dataid = UUIDService.generateUUID
          datatype = FORUM_REPLY
          update_attributes(metadata)
          datacreator = @serviceUUID unless post.datacreator
      end
      reply.save ? dataid : nil      
  end
  
  def ForumService.deleteReply(reply_uuid)
      reply = ForumReply.checkUUID(reply_uuid)
      reply ? reply.destroy : nil  
  end
  
  def ForumService.getReply(reply_uuid)
      reply = ForumReply.checkUUID(reply_uuid)
      reply ? reply : nil    
  end
  def ForumService.updateReply(reply_uuid,values)
      reply = ForumReply.checkUUID(reply_uuid)
      reply ? reply.update_attrbutes(values) : nil      
  end
    
end