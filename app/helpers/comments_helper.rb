# This helper has comments functions in it.
module CommentsHelper
	# Returns the path to comments. Usually something like
	# /countries/us/states/ok/cities/tulsa/wall/comments
	def get_comments_path
		wall = get_wall_path
		unless wall.nil?
			return "#{wall}/comments"
		end
	end

	# Returns the path to a specific comment, specified by id
	def get_comment_path(comment_id)
		comments = get_comments_path
		unless comments.nil?
			return "#{comments}/#{comment_id}"
		end
	end
end
