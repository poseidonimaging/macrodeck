class PermissionController < ApplicationController
	layout "lite", :except => :display_table
	
	# Display permission table
	def display_table

	end
	
	# Find user
	def find_user
		if @user_loggedin
		else
			render :text => nil
		end
	end
end
