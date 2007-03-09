class ForumService < BaseService

  def ForumService.createBoard(metadata)
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
  end
  
  # Deletes a post and all its replies (!)
  def ForumService.deletePost(post_uuid)
  end
  
  # Get post by given uuid
  def ForumService.getPost(post_uuid)
  end
  
  # Updates post by given uuid. 
  # +values+:: hash of updated values
  # == Example
  # ForumService.getPost(post_uuid,{:msg=>"hi jAck!"})
  def ForumService.updatePost(post_uuid,values)
  end
  
  # returns last post's reply
  def ForumService.getLastReply(post_uuid)
  end
  
  # returns true if post had been changed since given date
  def ForumService.isPostChanged?(since=nil)
  end
  

  # reply's methods' meaning are very similar to corresponding post's methods  
  
  def ForumService.createReply(post_uuid,msg,metadata)
  end
  
  def ForumService.deleteReply(reply_uuid)
  end
  
  def ForumService.getReply(reply_uuid)
  end
  def ForumService.updateReply(reply_uuid,values)
  end
    
end