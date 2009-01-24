class Facebook::HomeController < ApplicationController
	before_filter :require_facebook_login
	before_filter :initialize_facebook_user
	before_filter :get_networks
	before_filter :get_home_city
	before_filter :get_secondary_city
	layout "facebook/home"

	def index
		# Build the minifeed
		@minifeed = []
		@minifeed += minifeed_nudges_incoming unless minifeed_nudges_incoming.nil? || minifeed_nudges_incoming.length == 0
		@minifeed += minifeed_nudges_outgoing unless minifeed_nudges_outgoing.nil? || minifeed_nudges_outgoing.length == 0
		@minifeed += minifeed_patron_self unless minifeed_patron_self.nil? || minifeed_patron_self.length == 0
		@minifeed += minifeed_patron_friends unless minifeed_patron_friends.nil? || minifeed_patron_friends.length == 0
		@minifeed = @minifeed.sort.reverse[0..10]

		# Build the recommendations box.
		@recommendations = []
		@recommendations += recommendations_places unless recommendations_places.nil? || recommendations_places.length == 0
		@recommendations = @recommendations.sort.uniq[0..10]
	end

	private
		def place_type_to_string(type)
			types = PlaceMetadata.get_place_types
			return types[type]
		end

		# Finds friends who have a primary or secondary city in common with this user
		# then finds some places they patron that you haven't
		def recommendations_places
			recommendations = []

			rels = find_local_friend_relationships
			if rels && rels.length > 0
				rels.each do |r|
					# r is our friend that is in the same city (the relationship).
					places_to_check_out = relationships_not_in_common(@fbuser.uuid, r.source_uuid, "patron")
					places_to_check_out.each do |p|
						begin
							place = Place.find_by_uuid(p.target_uuid)
							user = User.find_by_uuid(r.source_uuid)
							if place.category == @home_city.category || place.category == @secondary_city.category
								found_rec = false
								recommendations.collect! do |rec|
									if rec.recommended_item == place
										rec.users_recommending << user
										found_rec = true
									end
									return rec
								end
								# add the recommendation if it doesn't exist yet.
								if !found_rec
									rec = Recommendation.new(place)
									rec.users_recommending << user
									recommendations << rec
								end
							end
						rescue
							nil
						end
					end
				end
			end

			return recommendations
		end

		# Returns relationships not in common between two UUIDs
		def relationships_not_in_common(source1, source2, relationship)
			rels = Relationship.find_by_sql(["SELECT * FROM relationships
											  WHERE target_uuid NOT IN ( SELECT target_uuid FROM relationships WHERE source_uuid = ? AND relationship = ? ) AND source_uuid = ? AND relationship = ?
											  LIMIT 0,500", source1, relationship, source2, relationship])
			return rels
		end

		# Returns relationships in the same home city/secondary city
		def find_local_friend_relationships
			if @home_city && @secondary_city
				# This query is complex so let's just do the SQL for it.
				# This finds all of your friends who share the same home or secondary city)
				rels = Relationship.find_by_sql(["SELECT * FROM relationships
												  WHERE source_uuid IN ( SELECT uuid FROM users AS U JOIN friends AS F ON U.id = F.user_id WHERE F.friend_id = ? )
													AND ( relationship = 'home_city' OR relationship = 'secondary_city' )
													AND ( target_uuid = ? OR target_uuid = ? )
												  LIMIT 0,500", @fbuser.id, @home_city.uuid, @secondary_city.uuid])
				return rels
			elsif @home_city && !@secondary_city
				# This query is complex so let's just do the SQL for it.
				# This finds all of your friends who share the same home or secondary city)
				rels = Relationship.find_by_sql(["SELECT * FROM relationships
												  WHERE source_uuid IN ( SELECT uuid FROM users AS U JOIN friends AS F ON U.id = F.user_id WHERE F.friend_id = ? )
													AND ( relationship = 'home_city' OR relationship = 'secondary_city' )
													AND ( target_uuid = ? )
												  LIMIT 0,500", @fbuser.id, @home_city.uuid])
				return rels
			else
				return nil
			end
		end

		# Places friends have patroned.
		def minifeed_patron_friends
			minifeed_items = []

			# Loop through friends and see if they have any places patronized. May slow execution time to a crawl in some
			# scenarios.... So limit the number of friends for now.
			@fbuser.friends[0..99].each do |friend|
				friend_patronages = Relationship.find(:all, :conditions => ["source_uuid = ? AND relationship = 'patron'", friend.uuid], :order => "updated_at", :limit => 50)
				friend_patronages.each do |p|
					begin
						place = Place.find_by_uuid(p.target_uuid)
						feed_item_text = "<fb:name uid='#{friend.facebook_uid}' linked='true' ifcantsee='A user' subjectid='#{@fbuser.facebook_uid}' /> became a patron of <a href='#{place.url(:facebook => true)}'>#{place.name}</a>."
						minifeed_items << [ p.updated_at, feed_item_text ]
					rescue
						nil
					end
				end
			end

			return minifeed_items
		end

		# Places you've patroned
		def minifeed_patron_self
			minifeed_items = []
			patronages = Relationship.find(:all, :conditions => ["source_uuid = ? AND relationship = 'patron'", @fbuser.uuid], :order => "updated_at", :limit => 50)
			if !patronages.nil? && patronages.length > 0
				patronages.each do |p|
					begin
						place = Place.find_by_uuid(p.target_uuid)
						feed_item_text = "You became a patron of <a href='#{place.url(:facebook => true)}'>#{place.name}</a>."
						minifeed_items << [ p.updated_at, feed_item_text ]
					rescue
						nil # do nothing
					end
				end
			end
			return minifeed_items
		end

		# Nudges sent to other users
		def minifeed_nudges_outgoing
			minifeed_items = []
			nudges = Relationship.find(:all, :conditions => ["source_uuid = ? AND subject IS NOT NULL AND relationship = 'nudged'", @fbuser.uuid], :order => "updated_at", :limit => 50)
			if !nudges.nil? && nudges.length > 0
				nudges.each do |nudge|
					# only the new-style nudges can say "you nudged X about Y"
					begin
						event = Event.find_by_uuid(nudge.subject)
						nudgee = User.find_by_uuid(nudge.target_uuid)
						feed_item_text = "You nudged <fb:name uid='#{nudgee.facebook_uid}' linked='true' ifcantsee='A user' subjectid='#{@fbuser.facebook_uid}' /> about <a href='#{event.url(:facebook => true)}'>#{event.summary}</a>."
						minifeed_items << [ nudge.updated_at, feed_item_text ]
					rescue
						nil # do nothing
					end
				end
			end
			return minifeed_items
		end

		# Nudges sent to you
		def minifeed_nudges_incoming
			minifeed_items = []
			nudges = Relationship.find(:all,
				:conditions => ["(target_uuid = ? AND subject IS NOT NULL AND relationship = 'nudged') OR
				  		 (source_uuid = ? AND subject IS NULL AND relationship = 'nudged')",
						@fbuser.uuid, @fbuser.uuid],
				:order => "updated_at",
				:limit => 50)
			if !nudges.nil? && nudges.length > 0
				nudges.each do |nudge|
					# Old nudge style lacked a sender thus we don't know who sent the nudge, but we can still show it
					if nudge.subject.nil?
						begin
							event = Event.find_by_uuid(nudge.target_uuid)
							feed_item_text = "You were nudged about <a href='#{event.url(:facebook => true)}'>#{event.summary}</a>."
							minifeed_items << [ nudge.updated_at, feed_item_text ]
						rescue
							nil # we won't do anything if any of the previous failed
						end
					else
						begin
							event = Event.find_by_uuid(nudge.subject)
							nudger = User.find_by_uuid(nudge.source_uuid)
							feed_item_text = "<fb:name uid='#{nudger.facebook_uid}' linked='true' ifcantsee='A user' subjectid='#{@fbuser.facebook_uid}' /> nudged you about
												<a href='#{event.url(:facebook => true)}'>#{event.summary}</a>."
							minifeed_items << [ nudge.updated_at, feed_item_text ]
						rescue
							nil # We don't do anything
						end
					end
				end
			end

			return minifeed_items
		end
end
