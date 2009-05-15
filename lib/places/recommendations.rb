module MacroDeck
	module Places
		class Recommendations
			def self.generate_fbml_for(recommendations)
				fbml = ActionView::Base.new(Rails::Configuration.new.view_path).render(:partial => 'facebook/home/recommendations', :locals => {:recommendations => recommendations, :facebook => true}) unless recommendations.length == 0
			end

			# Returns an array of recommendations.
			def self.generate_recommendations_for(user)
				recommendations = []
				recommendations += recommendations_places(user)
				recommendations += recommendations_popular_places(user)
				recommendations = merge_recommendations(recommendations)
				recommendations = recommendations.sort.reverse[0..14]
				return recommendations
			end

			private
				# Takes a recommendations array and merges items with the same place.
				def self.merge_recommendations(rec_arr)
					rec_h = {}
					new_rec_arr = []

					rec_arr.each do |r|
						# If the rec_h hash doesn't have this item in the list, add it,
						# otherwise, do a merge
						if rec_h[r.recommended_item].nil?
							rec_h[r.recommended_item] = r
						else
							# | = set union, joins the array while removing duplicates. Users don't change that often so this works.
							rec_h[r.recommended_item].users_recommending = rec_h[r.recommended_item].users_recommending | r.users_recommending
							rec_h[r.recommended_item].popularity += r.popularity
						end
					end
					
					# Now go through all of the values and return our new array.
					rec_h.each_value do |val|
						new_rec_arr << val
					end

					return new_rec_arr
				end

				# Finds friends who have a primary or secondary city in common with this user
				# then finds some places they patron that you haven't
				def self.recommendations_places(user)
					recommended_items = Array.new

					rels = find_local_friend_relationships(user)
					if rels && rels.length > 0
						rels.each do |r|
							# r is our friend that is in the same city (the relationship).
							places_to_check_out = relationships_not_in_common(user.uuid, r.source_uuid, "patron")
							places_to_check_out.each do |p|
								begin
									place = Place.find_by_uuid(p.target_uuid)
									rec_user = User.find_by_uuid(r.source_uuid)
									if (user.home_city && place.category == user.home_city.category) || (user.secondary_city && place.category == user.secondary_city.category)
										found_rec = false
										new_items = Array.new

										if recommended_items.length > 0
											recommended_items.each do |rec|
												if rec.recommended_item == place
													rec.users_recommending << rec_user
													found_rec = true
												end
												new_items << rec
											end
										end

										# add the recommendation if it doesn't exist yet.
										if !found_rec
											new_rec = Recommendation.new(place)
											new_rec.users_recommending << rec_user
											new_items << new_rec
										end

										# now set the recommended items to the new items.
										recommended_items = new_items
									end
								rescue
									nil
								end
							end
						end
					end

					return recommended_items
				end

				# Returns popular places in primary or secondary cities.
				def self.recommendations_popular_places(user)
					recommended_items = Array.new

					if user.home_city && user.secondary_city
						# multiple subqueries. here's what happens:
						# 1) get the UUID of all places in the city/cities
						# 2) get the most patron'ed places in that list by grouping and sorting by COUNT
						# 3) get a valid Place out of the list of most patroned places.
						popular_places = Place.find_by_sql(["SELECT * FROM data_objects
															 WHERE uuid IN (
																SELECT target_uuid FROM relationships
																WHERE target_uuid IN (
																	SELECT uuid FROM data_objects WHERE parent_id IN (?, ?) AND type = 'Place'
																)
																AND relationship = 'patron'
																GROUP BY target_uuid
																ORDER BY COUNT(id) DESC
															 ) LIMIT 0,500", user.home_city.id, user.secondary_city.id])
					elsif user.home_city && !user.secondary_city
						popular_places = Place.find_by_sql(["SELECT * FROM data_objects
															 WHERE uuid IN (
																SELECT target_uuid FROM relationships
																WHERE target_uuid IN (
																	SELECT uuid FROM data_objects WHERE parent_id = ? AND type = 'Place'
																)
																AND relationship = 'patron'
																GROUP BY target_uuid
																ORDER BY COUNT(id) DESC
															 ) LIMIT 0,500", user.home_city.id])				
					else
						return []
					end

					# Now iterate through this list and create a recommendation for each
					begin
						popular_places.each do |p|
							rec = Recommendation.new(p)
							rec.popularity = p.patrons.length
							recommended_items << rec
							#TODO: weight these slightly by being popular... probably only care about top 5 though.
						end
					rescue
						[]
					end

					return recommended_items
				end

				# Returns relationships not in common between two UUIDs
				def self.relationships_not_in_common(source1, source2, relationship)
					rels = Relationship.find_by_sql(["SELECT * FROM relationships
													  WHERE target_uuid NOT IN ( SELECT target_uuid FROM relationships WHERE source_uuid = ? AND relationship = ? ) AND source_uuid = ? AND relationship = ?
													  LIMIT 0,500", source1, relationship, source2, relationship])
					return rels
				end

				# Returns relationships in the same home city/secondary city
				def self.find_local_friend_relationships(user)
					if user.home_city && user.secondary_city
						# This query is complex so let's just do the SQL for it.
						# This finds all of your friends who share the same home or secondary city)
						rels = Relationship.find_by_sql(["SELECT * FROM relationships
														  WHERE source_uuid IN ( SELECT uuid FROM users AS U JOIN friends AS F ON U.id = F.user_id WHERE F.friend_id = ? )
															AND ( relationship = 'home_city' OR relationship = 'secondary_city' )
															AND ( target_uuid = ? OR target_uuid = ? )
														  LIMIT 0,500", user.id, user.home_city.uuid, user.secondary_city.uuid])
						return rels
					elsif user.home_city && !user.secondary_city
						# This query is complex so let's just do the SQL for it.
						# This finds all of your friends who share the same home or secondary city)
						rels = Relationship.find_by_sql(["SELECT * FROM relationships
														  WHERE source_uuid IN ( SELECT uuid FROM users AS U JOIN friends AS F ON U.id = F.user_id WHERE F.friend_id = ? )
															AND ( relationship = 'home_city' OR relationship = 'secondary_city' )
															AND ( target_uuid = ? )
														  LIMIT 0,500", user.id, user.home_city.uuid])
						return rels
					else
						return nil
					end
				end
		end
	end
end
