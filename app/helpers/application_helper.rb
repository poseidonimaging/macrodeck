# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def fb_tab_selected
		return 'selected="true"'
	end

	def fb_tab_not_selected
		return 'selected="false"'
	end

	# Outputs a three column layout
	# Expects an array of items as Strings that will be output.
	# WARNING: Include your own linebreaks if you need them!
	def threecol_layout(items)
		each_column = (items.length / 3.0).ceil
		first_column = items[0 .. each_column - 1]

		# prevents errors due to there being not enough items (e.g. less than 3)
		if items.length >= each_column
			second_column = items[each_column .. each_column + each_column - 1]
		else
			second_column = []
		end
		if items.length >= (each_column + each_column)
			third_column = items[each_column + each_column .. -1]
		else
			third_column = []
		end
		html = "<div class=\"threecol-layout\">
					<div class=\"threecol-first\">
						<div class=\"threecol-first-padding\">
							#{first_column.to_s}
						</div>
					</div>
					<div class=\"threecol-second\">
						<div class=\"threecol-second-padding\">
							#{second_column.to_s}
						</div>
					</div>
					<div class=\"threecol-third\">
						<div class=\"threecol-third-padding\">
							#{third_column.to_s}
						</div>
					</div>
				</div>"
		return html
	end

	# A URL helper that will hopefully override the default fbplaces_url and let you
	# link to crap easier.
	#
	# options_hash possible values:
	#   :action => (any action you wish... used in ../action/us/ok/tulsa/
	#   :country => (two-letter country code)
	#   :state => (two-letter state)
	#   :city => City object
	#   :place => Place object
	def fbplaces_url(options = {})
		url = "#{PLACES_FBURL}/"
		if options[:action] != nil && options[:action] != ""
			url << "#{url_sanitize(options[:action].to_s)}/"
		end
		if options[:country] != nil && options[:country] != ""
			url << "#{url_sanitize(options[:country])}/"
		end
		if options[:state] != nil && options[:state] != ""
			url << "#{url_sanitize(options[:state])}/"
		end
		if options[:city] != nil && options[:city] != ""
			url << "#{url_sanitize(options[:city])}/"
		end
		if options[:place] != nil && options[:place] != ""
			url << "#{url_sanitize(options[:place])}/"
		end
		return url
	end
end
