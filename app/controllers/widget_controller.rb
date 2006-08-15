class WidgetController < ApplicationController
	def get_components
		# This function currently doesn't do any
		# processing but in the future it will load
		# all of the components needed by a widget.
		# It currently does diddly.

		render :partial => "components"
	end
end
