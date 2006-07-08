# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	# Builds a summary with an optional title
	def build_summary(text, title = nil)
		if title != nil
			return "<h2>" + sanitize(title) + "</h2>\n" + markdown(sanitize(text))
		else
			return markdown(sanitize(text))
		end
	end
end
