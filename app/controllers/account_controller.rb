class AccountController < ApplicationController
	layout "default"
	
	def index
		# It's just a page.
	end
	def register
		# step 1 - username
		# step 2 - password, secret question, secret answer
		# step 3 - email, name, display name
		if @params[:step] == nil
			if @params[:username] == nil
				@username = nil
			else
				@username = @params[:username].downcase.gsub(/\W/, "").gsub(" ", "")
			end
			render :template => "account/register1"
		elsif @params[:step] == "1"
			# validate username
			@username = @params[:username].downcase.gsub(/\W/, "").gsub(" ", "") # should remove all non-word characters and remove spaces in case \W didn't catch them
			if @username.length > 0
				if UserService.doesUserExist?(@username) == false
					@origusername = @params[:username]
					render :template => "account/register2"
				else
					@error = "The username you picked is already in use."
					render :template => "account/register1"
				end
			else
				@error = "The username you picked is invalid."
				render :template => "account/register1"
			end
		elsif @params[:step] == "2"
			if request.method == :post
				# don't parse GET requests for sanity
				@username = @params[:username].downcase.gsub(/\W/, "").gsub(" ", "") # in case someone tries to trick their way into the system with a bad username
				@origusername = @params[:origusername] # this is for their "display name" which will be displayed on step 3.
				@secretquestion = @params[:secretquestion]
				@secretanswer = @params[:secretanswer]
				# validate password
				if @params[:password1] != @params[:password2]
					@error = "Your passwords don't match."
					render :template => "account/register2"
				else
					# passwords match, are they long enough?
					@password = @params[:password1]
					if @password.length < 5
						@error = "Your password is too short (must be at least 5 characters long)."
						render :template => "account/register2"
					else
						# okay, they're long enough. what about the secret question?
						if @params[:secretquestion].length == 0
							@error = "You must enter a secret question."
							render :template => "account/register2"
						else
							# and what about the secret answer?
							if @params[:secretanswer].length == 0
								@error = "You must enter a secret answer."
								render :template => "account/register2"
							else
								# all is go! go to step 3.
								render :template => "account/register3"
							end						
						end	
					end				
				end
			else
				raise "Accessing account/register#2 via unsupported HTTP method!"
			end
		elsif @params[:step] == "3"
			if request.method == :post
				@username = @params[:username].downcase.gsub(/\W/, "").gsub(" ", "") # wise guy, eh?
				@origusername = @params[:displayname]
				@secretquestion = @params[:secretquestion]
				@secretanswer = @params[:secretanswer]
				@password = @params[:password]
				@email = @params[:email]
				@displayname = @params[:displayname]
				@name = @params[:name]
				# Validate e-mail address
				if email_valid?(@email) == false
					@error = "Please enter a valid e-mail address."
					render :template => "account/register3"
				else
					# email is valid, check if display name is filled in.
					if @origusername.length == 0
						@error = "You have not entered a display name."
						render :template => "account/register3"
					else
						# that's valid, check the password.
						if @password.length == 0
							@error = "Somehow your password is blank. This is probably a filter or some Internet security software running on your computer. Please try registering again from the <a href=\"/account/register\">beginning</a>."
							render :template => "account/register3"
						else
							# okay, the password isn't screwy. check the secret question
							if @secretquestion.length == 0
								@error = "Somehow your secret question is blank. This is probably a filter or some Internet security software running on your computer. Please try registering again from the <a href=\"/account/register\">beginning</a>."
								render :template => "account/register3"
							else
								# secret question is good, check secret answer
								if @secretanswer.length == 0
									@error = "Somehow your secret answer is blank. This is probably a filter or some Internet security software running on your computer. Please try registering again from the <a href=\"/account/register\">beginning</a>."
									render :template => "account/register3"
								else
									# secret answer is good, check username in case they're attempting to specify a null one.
									if @username.length == 0
										@error = "Somehow your username is blank. This is probably a filter or some Internet security software running on your computer. Please try registering again from the <a href=\"/account/register\">beginning</a>."
										render :template => "account/register3"
									else
										# it checks out, boss!
										# UserService.createUser(userName, password, secretQuestion, secretAnswer, name, displayName)
										uuid = UserService.createUser(@username, @password, @secretquestion, @secretanswer, @name, @displayname)
										if uuid != nil
											render :template => "account/registerdone"
										else
											@error = "There was an error creating your user account. Please try again."
											render :template => "account/register3"
										end
									end
								end
							end
						end
					end
				end
			else
				raise "Accessing account/register#3 via unsupported HTTP method!"
			end
		else
			raise "Unknown action in account/register!"
		end
	end
	def login
	end
end
