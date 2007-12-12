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
end
