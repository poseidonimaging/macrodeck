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
					part = HtmlPart.find_or_initialize_by_user_id_and_urn(user.id, "macrodeck/home/recommendations.fbml")
					if part.content == fbml
						"--- Content does not differ"
					else
						part.update_attributes!(:content => fbml)
					end
				else
					puts "--- No data for user, skipping"
				end
				puts "--- Done processing UID:#{user.facebook_uid}"
			end
		end
	end
end
