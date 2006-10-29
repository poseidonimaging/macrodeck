class PermissionController < ApplicationController
	layout "lite", :except => :display_table
	
	# Display permission table
	def display_table
	end
	
	# Find user
	def find_user
		if @user_loggedin
			if @params["step"] != nil && @params["step"] == "lookup"
				# Currently we only care about exact username matches
				usergroup = UserService.lookupUserName(@params["usergroup"].downcase)
				if usergroup == nil
					usergroup = UserService.lookupGroupName(@params["usergroup"].downcase)
					if usergroup == nil
						@errors << "Invalid user or group name"
						@params["step"] = "home"
					else
						@uuid = usergroup
						@name = UserService.lookupUUID(@uuid)
						@uname = @params["usergroup"].downcase
						@kind = @params["kind"]
					end
				else
					@uuid = usergroup
					@name = UserService.lookupUUID(@uuid)
					@uname = @params["usergroup"].downcase
					@kind = @params["kind"]
				end
			end
		else
			render :text => nil
		end
	end
	
	# Parse permissions array
	def self.parse_permissions(perms)
		# Sample:
		# {
		#   "0"=>{"everybody"=>"deny"},
		#   "1"=>{"253d41a1-8b62-4ca8-9f8d-99bb42bc0dd8"=>"allow"}
		# }
		perm_array = Array.new
		perms = perms.sort
		perms.each do |perm|
			perm[1].each_pair do |key, value|
				if value == "deny" || value == "allow"
					perm_array << { :id => key, :action => value }
				end
			end
		end
		raise perm_array.inspect
	end
end
