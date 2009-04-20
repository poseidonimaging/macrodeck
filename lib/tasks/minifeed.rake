require "places/minifeed"

namespace :macrodeck do
	namespace :batch do
		desc "Runs through users and generates HtmlParts for their minifeeds"
		task(:minifeed => :environment) do
			User.find(:all, :conditions => ["facebook_uid IS NOT NULL"]).each do |user|
				puts "--- Now processing UID:#{user.facebook_uid}"
				minifeed = MacroDeck::Places::Minifeed.generate_minifeed_for(user)
				fbml = MacroDeck::Places::Minifeed.generate_fbml_for(minifeed)
				if fbml
					part = HtmlPart.find(:first, :conditions => ["user_id = ? AND urn = 'macrodeck/home/minifeed.fbml'", user.id])
					if part.nil?
						part = HtmlPart.new(:user => user, :urn => "macrodeck/home/minifeed.fbml")
					end
					part.content = fbml
					part.save!
				else
					puts "--- No data for UID:#{user.facebook_uid}, skipping"
				end
				puts "--- Done processing UID:#{user.facebook_uid}"
			end
		end
	end
end
