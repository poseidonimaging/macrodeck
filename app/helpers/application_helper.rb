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
	
	# Builds tab display
	def build_tabs
		tabs_html = "<ul class=\"tabs\">"
		@tabs.each do |tab|
			if tab[:id] == @current_tab
				tab_left_class = "tab-left-active"
				tab_right_class = "tab-right-active"
				tab_fill_class = "tab-fill-active"
			else
				tab_left_class = "tab-left"
				tab_right_class = "tab-right"
				tab_fill_class = "tab-fill"
			end
			tab_html = "<li class=\"tab\"><div class=\"#{tab_left_class}\"><div class=\"#{tab_right_class}\"><div class=\"#{tab_fill_class}\"><div>" + link_to(tab[:text], tab[:url]) + "</div></div></div></div></li>"
			tabs_html << tab_html
		end
		tabs_html << "</ul>"
		return tabs_html
	end
end
