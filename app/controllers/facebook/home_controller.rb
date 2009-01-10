class Facebook::HomeController < ApplicationController
	before_filter :require_facebook_login
	before_filter :initialize_facebook_user
	layout "facebook/home"

	def index
		@minifeed = []
		@minifeed += minifeed_nudges_incoming unless minifeed_nudges_incoming.nil? || minifeed_nudges_incoming.length == 0
		@minifeed += minifeed_nudges_outgoing unless minifeed_nudges_outgoing.nil? || minifeed_nudges_outgoing.length == 0
		@minifeed.sort!.reverse![0..10]
	end

	private
		def minifeed_nudges_outgoing
			minifeed_items = []
			nudges = Relationship.find(:all,
				:conditions => ["source_uuid = ? AND subject IS NOT NULL AND relationship = 'nudged'", @fbuser.uuid],
				:order => "updated_at DESC")
			if !nudges.nil? && nudges.length > 0
				nudges.each do |nudge|
					# only the new-style nudges can say "you nudged X about Y"
					begin
						event = Event.find_by_uuid(nudge.subject)
						nudgee = User.find_by_uuid(nudge.target_uuid)
						feed_item_text = "You nudged <fb:name uid='#{nudgee.facebook_uid}' linked='true' ifcantsee='A user' subjectid='#{@fbuser.facebook_uid}' /> about <a href='#{event.url(:facebook => true)}'>#{event.summary}</a>"
						minifeed_items << [ nudge.updated_at, feed_item_text ]
					rescue
						nil # do nothing
					end
				end
			end
			return minifeed_items
		end

		def minifeed_nudges_incoming
			minifeed_items = []
			nudges = Relationship.find(:all,
				:conditions => ["(target_uuid = ? AND subject IS NOT NULL AND relationship = 'nudged') OR
				  		 (source_uuid = ? AND subject IS NULL AND relationship = 'nudged')",
						@fbuser.uuid, @fbuser.uuid],
				:order => "updated_at DESC")
			if !nudges.nil? && nudges.length > 0
				nudges.each do |nudge|
					# Old nudge style lacked a sender thus we don't know who sent the nudge, but we can still show it
					if nudge.subject.nil?
						begin
							event = Event.find_by_uuid(nudge.target_uuid)
							feed_item_text = "You were nudged about <a href='#{event.url(:facebook => true)}'>#{event.summary}</a>"
							minifeed_items << [ nudge.updated_at, feed_item_text ]
						rescue
							nil # we won't do anything if any of the previous failed
						end
					else
						begin
							event = Event.find_by_uuid(nudge.subject)
							nudger = User.find_by_uuid(nudge.source_uuid)
							feed_item_text = "<fb:name uid='#{nudger.facebook_uid}' linked='true' ifcantsee='A user' subjectid='#{@fbuser.facebook_uid}' /> nudged you about
												<a href='#{event.url(:facebook => true)}'>#{event.summary}</a>"
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
