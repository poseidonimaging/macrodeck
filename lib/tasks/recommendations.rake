require "places/recommendations"

namespace :macrodeck do
	namespace :batch do
		desc "Runs through users and generates HtmlParts for their recommendations"
		task(:recommendations => :environment) do
			User.find(:all, :conditions => ["facebook_uid IS NOT NULL"]).each do |user|
				puts "--- Now processing UID:#{user.facebook_uid}"
				recommendations = MacroDeck::Places::Recommendations::generate_recommendations_for(user)
				fbml = MacroDeck::Places::Recommendations::generate_fbml_for(recommendations)
				if fbml
					part = HtmlPart.find(:first, :conditions => ["user_id = ? AND urn = 'macrodeck/home/recommendations.fbml'", user.id])
					if part.nil?
						part = HtmlPart.new(:user => user, :urn => "macrodeck/home/recommendations.fbml")
					end
					part.content = fbml
					part.save!
				else
					puts "--- No data for user, skipping"
				end
				puts "--- Done processing UID:#{user.facebook_uid}"
			end
		end
	end
end
