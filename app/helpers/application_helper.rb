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

	# Returns HTML for an hour picker having the HTML name specified.
	# To work around Facebook's time picker not doing timezones in the least bit
	# correctly.
	def hour_picker(name, default = 0)
		html = ""
		html << "<select name='#{name}' id='#{name}'>"
		i = 0
		if default.to_i > 12
			default = default.to_i - 12
		end
		12.times do
			i = i + 1
			if default.to_i == i
				html << "<option value='#{i}' selected='selected'>#{i}</option>"
			else
				html << "<option value='#{i}'>#{i}</option>"
			end
		end
		html << "</select>"
		return html
	end

	# Returns HTML for a minute picker, staggered every 5 minutes. Because Facebook sucks.
	def minute_picker(name, default = 0)
		html = ""
		html << "<select name='#{name}' id='#{name}'>"
		["00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"].each do |t|
			if default.to_i == t.to_i
				html << "<option value='#{t}' selected='selected'>#{t}</option>"
			else
				html << "<option value='#{t}'>#{t}</option>"
			end
		end
		html << "</select>"
		return html
	end

	# Returns HTML for an AM/PM picker
	def ampm_picker(name, default = "am")
		html  = ""
		html << "<select name='#{name}' id='#{name}'>"
		["am", "pm"].each do |t|
			if default == t
				html << "<option value='#{t}' selected='selected'>#{t}</option>"
			else
				html << "<option value='#{t}'>#{t}</option>"
			end
		end
		html << "</select>"
		return html
	end

	# Returns HTML for a month picker having the HTML name specified.
	# Optionally can specify the month and it will make it selected.
	def month_picker(name, default = 0)
		html = ""
		html << "<select name='#{name}' id='#{name}'>"
		i = 0
		MONTHS_EN.each do |m|
			i = i + 1
			if default.to_i == i
				html << "<option value='#{i}' selected='selected'>#{m}</option>"
			else
				html << "<option value='#{i}'>#{m}</option>"
			end
		end
		html << "</select>"
		return html
	end

	# Returns HTML for a day picker having the HTML name specified.
	def day_picker(name, default = 0)
		html = ""
		html << "<select name='#{name}' id='#{name}'>"
		i = 0
		31.times do
			i = i + 1
			if default.to_i == i
				html << "<option value='#{i}' selected='selected'>#{i}</option>"
			else
				html << "<option value='#{i}'>#{i}</option>"
			end
		end
		html << "</select>"
		return html
	end

	# Returns HTML for a year picker, having the HTML name specified
	def year_picker(name, default = 0)
		html = ""
		html << "<select name='#{name}' id='#{name}'>"
		i = Time.now.year
		10.times do
			if default.to_i == i
				html << "<option value='#{i}' selected='selected'>#{i}</option>"
			else
				html << "<option value='#{i}'>#{i}</option>"
			end
			i = i + 1
		end
		html << "</select>"
		return html
	end

	# Outputs a content module. Usage:
	# <% content_module "Title" do %>
	#	Content here
	# <% end %>
	#
	# Options:
	# +box_size+	: 25, 50, 75, or 100, specifies the width. Default is 100.
	# +altbox+		: true/false, renders the box in a different color.
	def content_module(title, options = {}, &block)
		options[:box_size] = 100 if options[:box_size].nil?
		p options
		block_to_partial 'common/content_module', options.merge(:title => title), &block
	end

	# Supports the new layout's module functions.
	def block_to_partial(partial_name, options = {}, &block)
		options.merge!(:body => capture(&block))
		concat(render(:partial => partial_name, :locals => options))
	end
end
