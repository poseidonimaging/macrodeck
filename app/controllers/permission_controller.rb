class PermissionController < ApplicationController
	# Display permission table
	def display_table
		if @params[:permissions] != nil
			if @params[:kind] != nil
				@kind = @params[:kind]
			else
				@kind = "permission"
			end
			render :partial => 'permission/permtable'
		else
			render :text => nil
		end
	end
end
