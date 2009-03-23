# MacroDeck namespace
module MacroDeck
	# Places namespace
	module Places
		# Ratings controller functions - to move them out of the controller for ease of
		# porting and stuff.
		module Ratings
			def like
				if params[:place]
					@place = Place.find_by_uuid(params[:place])
					if @place != nil
						relationship_exists = Relationship.find(:first, :conditions => ["source_uuid = ? AND target_uuid = ? AND relationship IN ('like','dislike')", @fbuser.uuid, @place.uuid])

						# If they're able to change their mind, let them.
						if relationship_exists && 60.days.since(my_rating.updated_at) <= Time.now
							relationship_exists.destroy
							relationship_exists = nil
						end

						if relationship_exists.nil?
							new_rel = Relationship.new do |r|
								r.source_uuid = @fbuser.uuid
								r.target_uuid = @place.uuid
								r.relationship = "like"
							end
							new_rel.save!

							# Now publish this to their feed.
							feed_tokens = {
								"place"			=> @place.name,
								"placeurl"		=> @place.url,
								"type"			=> @place.place_metadata.place_type_to_s,
								"placeinfo"		=> @place.description,
								"location"		=> "#{@place.city.name}, #{@place.city.state(:abbreviation => true)}",
								"thumb"			=> "thumbs up"
							}
							feed_tokens = feed_tokens.to_json
							fbsession.feed_publishUserAction( :template_bundle_id => FB_FEED_RATING, :template_data => feed_tokens )
						end
					end
					redirect_to @place.url(:facebook => true)
				end
			end
			def dislike
				if params[:place]
					@place = Place.find_by_uuid(params[:place])
					if @place != nil
						relationship_exists = Relationship.find(:first, :conditions => ["source_uuid = ? AND target_uuid = ? AND relationship IN ('like','dislike')", @fbuser.uuid, @place.uuid])
						
						# If they're able to change their mind, let them.
						if relationship_exists && 60.days.since(my_rating.updated_at) <= Time.now
							relationship_exists.destroy
							relationship_exists = nil
						end

						if relationship_exists.nil?
							new_rel = Relationship.new do |r|
								r.source_uuid = @fbuser.uuid
								r.target_uuid = @place.uuid
								r.relationship = "dislike"
							end
							new_rel.save!

							# Now publish this to their feed.
							feed_tokens = {
								"place"			=> @place.name,
								"placeurl"		=> @place.url,
								"type"			=> @place.place_metadata.place_type_to_s,
								"placeinfo"		=> @place.description,
								"location"		=> "#{@place.city.name}, #{@place.city.state(:abbreviation => true)}",
								"thumb"			=> "thumbs down"
							}
							feed_tokens = feed_tokens.to_json
							fbsession.feed_publishUserAction( :template_bundle_id => FB_FEED_RATING, :template_data => feed_tokens )
						end
					end
					redirect_to @place.url(:facebook => true)
				end
			end
		end
	end
end
