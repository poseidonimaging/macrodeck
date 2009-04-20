require "places/minifeed"

namespace :macrodeck do
	namespace :batch do
		desc "Runs through users and generates HtmlParts for their recommendations"
		task(:recommendations => :environment) do
			User.find(:all, :conditions => ["facebook_uid IS NOT NULL"]).each do |user|
				recommendations = MacroDeck::Places::Recommendations::generate_recommendations_for(user)
				fbml = MacroDeck::Places::Recommendations::generate_fbml_for(recommendations)
				part = HtmlPart.find(:first, :conditions => ["user_id = ? AND urn = 'macrodeck/home/recommendations.fbml'", user.id])
				if part.nil?
					part = HtmlPart.new(:user => user, :urn => "macrodeck/home/recommendations.fbml")
				end
				part.content = fbml
				part.save!
			end
		end
	end
end
