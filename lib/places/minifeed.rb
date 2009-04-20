module MacroDeck
	module Places
		class Minifeed
			# Generate FBML for a minifeed
			def self.generate_fbml_for(minifeed)
				fbml = ActionView::Base.new(Rails::Configuration.new.view_path).render(:partial => 'facebook/home/minifeed', :locals => {:minifeed => minifeed}) unless minifeed.length == 0
			end

			# Generate a minifeed array for rendering
			def self.generate_minifeed_for(user)
				# Build the minifeed
				minifeed = []
				minifeed += minifeed_nudges_incoming(user)
				minifeed += minifeed_nudges_outgoing(user)
				minifeed += minifeed_patron_self(user)
				minifeed += minifeed_patron_friends(user)
				minifeed = minifeed.sort.reverse[0..14]
				return minifeed
			end

			private
				# Places friends have patroned.
				def self.minifeed_patron_friends(user)
					minifeed_items = []

					# Loop through friends and see if they have any places patronized. May slow execution time to a crawl in some
					# scenarios.... So limit the number of friends for now.
					user.friends[0..99].each do |friend|
						friend_patronages = Relationship.find(:all, :conditions => ["source_uuid = ? AND relationship = 'patron'", friend.uuid], :order => "updated_at", :limit => 50)
						friend_patronages.each do |p|
							begin
								place = Place.find_by_uuid(p.target_uuid)
								feed_item_text = "<fb:name uid='#{friend.facebook_uid}' linked='true' ifcantsee='A user' subjectid='#{user.facebook_uid}' /> became a patron of <a href='#{place.url(:facebook => true)}'>#{place.name}</a>."
								minifeed_items << [ p.updated_at, feed_item_text ]
							rescue
								nil
							end
						end
					end

					return minifeed_items
				end

				# Places you've patroned
				def self.minifeed_patron_self(user)
					minifeed_items = []
					patronages = Relationship.find(:all, :conditions => ["source_uuid = ? AND relationship = 'patron'", user.uuid], :order => "updated_at", :limit => 50)
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
				def self.minifeed_nudges_outgoing(user)
					minifeed_items = []
					nudges = Relationship.find(:all, :conditions => ["source_uuid = ? AND subject IS NOT NULL AND relationship = 'nudged'", user.uuid], :order => "updated_at", :limit => 50)
					if !nudges.nil? && nudges.length > 0
						nudges.each do |nudge|
							# only the new-style nudges can say "you nudged X about Y"
							begin
								event = Event.find_by_uuid(nudge.subject)
								nudgee = User.find_by_uuid(nudge.target_uuid)
								feed_item_text = "You nudged <fb:name uid='#{nudgee.facebook_uid}' linked='true' ifcantsee='A user' subjectid='#{user.facebook_uid}' /> about <a href='#{event.url(:facebook => true)}'>#{event.summary}</a>."
								minifeed_items << [ nudge.updated_at, feed_item_text ]
							rescue
								nil # do nothing
							end
						end
					end
					return minifeed_items
				end

				# Nudges sent to you
				def self.minifeed_nudges_incoming(user)
					minifeed_items = []
					nudges = Relationship.find(:all,
						:conditions => ["(target_uuid = ? AND subject IS NOT NULL AND relationship = 'nudged') OR
								 (source_uuid = ? AND subject IS NULL AND relationship = 'nudged')",
								user.uuid, user.uuid],
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
									feed_item_text = "<fb:name uid='#{nudger.facebook_uid}' linked='true' ifcantsee='A user' subjectid='#{user.facebook_uid}' /> nudged you about
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
	end
end
