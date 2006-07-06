# This service provides user support across MacroDeck.
# This service requires UUIDService to work correctly.
# It also depends on the existance of Rails, or at
# least ActiveRecord. It also requires digest/sha2.

require 'digest/sha2'
require 'user'
require 'group'
require 'group_member'

class UserService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.UserService"
	@serviceName = "UserService"	
	@serviceVersionMajor = 1
	@serviceVersionMinor = 0	
	@serviceVersionRevision = 20060704
	@serviceUUID = "8d6e8d29-55b0-4d74-bf71-84b2d653ba1f"
	
	# Creates a new user in the database, first checking to see if the user exists or not.
	# Returns the new user's UUID.
	def self.createUser(userName, password, passHint, secretQuestion, secretAnswer, name, displayName, dob)
		if self.doesUserExist?(userName) == false
			user = User.new
			user.uuid = UUIDService.generateUUID
			user.username = userName.downcase
			if defined?(PASSWORD_SALT)
				user.password = "sha512:" + Digest::SHA512::hexdigest(PASSWORD_SALT + ":" + password)
			else
				user.password = "sha512:" + Digest::SHA512::hexdigest(password)
			end
			user.passwordhint = passHint
			user.secretquestion = secretQuestion
			user.secretanswer = secretAnswer
			user.name = name
			user.displayname = displayName
			user.creation = Time.now.to_i
			user.dob = dob
			user.save!
			return user.uuid
		else
			return nil
		end
	end
	
	# Returns true if the user specified exists, returns false if the
	# user specified does not exist.
	def self.doesUserExist?(userName)
		user = User.find(:first, :conditions => ["username = ?", userName.downcase])
		if user == nil
			return false
		else
			return true
		end
	end
	
	# Returns an authentication code and creates a session.
	# AuthCodes can be used to perform actions on behalf
	# of this user (i.e. from remote sites).
	def self.authenticate(userName, password)
		if self.doesUserExist?(userName)
			user = User.find(:first, :conditions => ["username = ?", userName.downcase])
			if defined?(PASSWORD_SALT)
				if user.password == "sha512:" + Digest::SHA512::hexdigest(PASSWORD_SALT + ":" + password)
					# create an authcode.
					authcode = createAuthCode(userName, user.password)
					# set the authcode
					user.authcode = authcode
					reset_session
					session[:authcode] = authcode
					session[:uuid] = user.uuid
				end
			else
			end
		end
	end
	
	# Gets the requested user property of the user specified.
	# Users are specified by UUID and authCode. Valid properties:
	# :username, :passwordhint, :secretquestion, :secretanswer
	# :name, :displayname, :creation, and :dob.
	def self.getUserProperty(uuid, authCode, property)
		user = User.find(:first, :conditions => ["uuid = ? AND authcode = ?", uuid, authCode])
		if user != nil
			# get the property requested.
			case property
				when :username, "username"
					return user.username
				when :passwordhint, "passwordhint"
					return user.passwordhint
				when :secretquestion, "secretquestion"
					return user.secretquestion
				when :secretanswer, "secretanswer"
					return user.secretanswer
				when :name, "name"
					return user.name
				when :displayname, "displayname"
					return user.displayname
				when :creation, "creation"
					return user.creation
				when :dob, "dob"
					return user.dob
				else
					return nil
			end
		else
			# invalid information
			return nil
		end
	end
	
	# Creates a group with the information specified.
	def self.createGroup(groupName, displayname)
		if self.doesGroupExist?(groupName) == false
			# Can create the group since it doesn't exist.
			group = Group.new
			group.uuid = UUIDService.generateUUID
			group.name = groupName.downcase
			group.displayname = displayname
			group.save!
		end
	end
	
	# Returns true if a group exists, false if one
	# does not.
	def self.doesGroupExist?(groupName)
		group = Group.find(:first, :conditions => ["name = ?", groupName.downcase])
		if group == nil
			return false
		else
			return true
		end
	end
	
	# Creates an authentication code based on information
	# that can be retrieved in the function and a username
	# and password hash that are specified.
	def self.createAuthCode(userName, passHash)
		ipaddr = @request.env['REMOTE_ADDR']
		ipaddr_arr = ipaddr.split(".")
		return Digest::SHA512::hexdigest(userName + ":" + passHash + ":" + @request.env['HTTP_USER_AGENT'] + ":" + ipaddr_arr[0] + ":" + ipaddr_arr[1] + ":" + ipaddr_arr[2] + ":" + Time.now.mon)
	end
end

Services.registerService(UserService)