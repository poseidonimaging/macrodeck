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
	@serviceVersionMajor = 0
	@serviceVersionMinor = 2
	@serviceVersionRevision = 20060705
	@serviceUUID = "8d6e8d29-55b0-4d74-bf71-84b2d653ba1f"
	
	# Creates a new user in the database, first checking to see if the user exists or not.
	# Returns the new user's UUID.
	def self.createUser(userName, password, secretQuestion, secretAnswer, name, displayName, email)
		if self.doesUserExist?(userName) == false
			user = User.new
			user.uuid = UUIDService.generateUUID
			user.username = userName.downcase
			if defined?(PASSWORD_SALT)
				user.password = "sha512:" + Digest::SHA512::hexdigest(PASSWORD_SALT + ":" + password)
			else
				user.password = "sha512:" + Digest::SHA512::hexdigest(password)
			end
			# removed 10-July-2006 by Ziggy #user.passwordhint = passHint
			user.secretquestion = secretQuestion
			user.secretanswer = secretAnswer
			user.name = name
			user.displayname = displayName
			user.creation = Time.now.to_i
			# removed 10-July-2006 by Ziggy #user.dob = dob
			user.email = email
			user.verified_email = false
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
	
	# Returns true if the UUID matches a user.
	def self.isUser?(uuid)
		user = User.find(:first, :conditions => ["uuid = ?", uuid])
		if user != nil
			return true
		else
			return false
		end
	end
	
	# Returns true if the UUID matches a group.
	def self.isGroup?(uuid)
		group = Group.find(:first, :conditions => ["uuid = ?", uuid])
		if group != nil
			return true
		else
			return false
		end
	end
	
	# Returns true if a group member exists, false
	# if one does not.
	def self.doesGroupMemberExist?(groupID, userID)
		groupmember = GroupMember.find(:first, :conditions => ["groupid = ? AND userid = ?", groupID, userID])
		if groupmember == nil
			return false
		else
			return true
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
	
	# Returns an authentication code, does NOT create a session.
	# AuthCodes can be used to perform actions on behalf
	# of this user (i.e. from remote sites).
	def self.authenticate(userName, password, ipAddress)
		if self.doesUserExist?(userName)
			user = User.find(:first, :conditions => ["username = ?", userName.downcase])
			if defined?(PASSWORD_SALT)
				if user.password == "sha512:" + Digest::SHA512::hexdigest(PASSWORD_SALT + ":" + password)
					# create an authcode.
					authcode = createAuthCode(userName, user.password, ipAddress)
					# set the authcode
					user.authcode = authcode
					user.save!
					return { :authcode => authcode, :uuid => user.uuid }
				else
					return nil
				end
			else
				if user.password == "sha512:" + Digest::SHA512::hexdigest(password)
					# create an authcode.
					authcode = createAuthCode(userName, user.password, ipAddress)
					# set the authcode
					user.authcode = authcode
					user.save!
					return { :authcode => authcode, :uuid => user.uuid }
				else
					return nil
				end
			end
		else
			# User doesn't exist.
			return nil
		end
	end
	
	# Gets the requested user property of the user specified.
	# Users are specified by UUID and authCode. Valid properties:
	# :username, :secretquestion, :secretanswer
	# :name, :displayname, :creation, and :verified_email
	def self.getUserProperty(uuid, authCode, property)
		user = User.find(:first, :conditions => ["uuid = ? AND authcode = ?", uuid, authCode])
		if user != nil
			# get the property requested.
			case property
				when :username, "username"
					return user.username
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
				when :verified_email, "verified_email"
					return user.verified_email
				when :email, "email"
					return user.email
				else
					return nil
			end
		else
			# invalid information
			return nil
		end
	end

	# Sets the requested user property of the user specified.
	# Users are specified by UUID and authCode. Valid properties:
	# :secretquestion, :secretanswer, :name, :displayname, :password,
	# and :email. :password will automatically be encrypted.
	def self.setUserProperty(uuid, authCode, property, value)
		user = User.find(:first, :conditions => ["uuid = ? AND authcode = ?", uuid, authCode])
		if user != nil
			# get the property requested.
			case property
				when :secretquestion, "secretquestion"
					user.secretquestion = value
				when :secretanswer, "secretanswer"
					user.secretanswer = value
				when :name, "name"
					user.name = value
				when :displayname, "displayname"
					user.displayname = value
				when :email, "email"
					user.email = value
				when :password, "password"
					if defined?(PASSWORD_SALT)
						user.password = "sha512:" + Digest::SHA512::hexdigest(PASSWORD_SALT + ":" + value)
					else
						user.password = "sha512:" + Digest::SHA512::hexdigest(value)
					end
				else
					return false
			end
			user.save!
			return true
		else
			# invalid information
			return false
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
	
	# Adds a user to a group. Level may be
	# :administrator, :moderator, or :user.
	def self.addUserToGroup(groupID, userID, level)
		if self.doesGroupMemberExist?(groupID, userID) == false
			# only add if the user doesn't already exist
			groupmember = GroupMember.new
			groupmember.groupid = groupID
			groupmember.userid = userID
			case level
				when :administrator, "administrator"
					groupmember.level = "administrator"
				when :moderator, "moderator"
					groupmember.level = "moderator"
				when :user, "user"
					groupmember.level = "user"
				else
					raise ArgumentError, "Valid group level not specified", caller
			end
			groupmember.isbanned = false
			groupmember.save!
		end
	end
	
	# Removes a user from a group.
	def self.removeUserFromGroup(groupID, userID)
		groupmember = GroupMember.find(:first, :conditions => ["groupid = ? AND userid = ?", groupID, userID])
		if groupmember != nil
			groupmember.destroy
		end
	end
	
	# Sets a particular user in a group as banned
	def self.banGroupMember(groupID, userID)
		groupmember = GroupMember.find(:first, :conditions => ["groupid = ? AND userid = ?", groupID, userID])
		if groupmember != nil
			groupmember.isbanned = true
			groupmember.save!
		end
	end
	
	# Unsets a particular user in a group as banned
	def self.unbanGroupMember(groupID, userID)
		groupmember = GroupMember.find(:first, :conditions => ["groupid = ? AND userid = ?", groupID, userID])
		if groupmember != nil
			groupmember.isbanned = false
			groupmember.save!
		end
	end
	
	# Changes a user's level within a group. See addUserToGroup for
	# a list of valid levels.
	def self.changeGroupMemberLevel(groupID, userID, newLevel)
		if self.doesGroupMemberExist?(groupID, userID)
			groupmember = GroupMember.find(:first, :conditions => ["groupid = ? AND userid = ?", groupID, userID])
			case newLevel
				when :administrator, "administrator"
					groupmember.level = "administrator"
				when :moderator, "moderator"
					groupmember.level = "moderator"
				when :user, "user"
					groupmember.level = "user"
				else
					raise ArgumentError, "Valid group level not specified", caller
			end
			groupmember.save!
		end
	end
	
	# Creates an authentication code based on information
	# that can be retrieved in the function and a username
	# and password hash that are specified.
	def self.createAuthCode(userName, passHash, ipAddress)
		ipaddr_arr = ipAddress.split(".")
		return Digest::SHA512::hexdigest(userName + ":" + passHash + ":" + ipaddr_arr[0].to_s + ":" + ipaddr_arr[1].to_s + ":" + ipaddr_arr[2].to_s + ":" + Time.now.mon.to_s)
	end
	
	# Returns an array (that contains hashes) of the users
	# that are members of a group. The hashes returned are
	# in the following format:
	#
	#  { :uuid => "User's UUID", :level => :administrator, :isbanned => true }
	#
	# Keeping in mind that :level may be any possible in
	# addUserToGroup. And :isbanned can be false.
	def self.getGroupMembers(groupID)
		groupmembers = GroupMember.find(:all, :conditions => ["groupid = ?", groupID])
		members = Array.new
		groupmembers.each do |member|
			case member.level
				when "administrator"
					h = { :uuid => member.userid, :level => :administrator, :isbanned => member.isbanned }
				when "moderator"
					h = { :uuid => member.userid, :level => :moderator, :isbanned => member.isbanned }
				when "user"
					h = { :uuid => member.userid, :level => :user, :isbanned => member.isbanned }
			end
			members << h
		end
		return members
	end
	
	# Returns the UUID of the group name specified.
	def self.lookupGroupName(groupName)
		group = Group.find(:first, :conditions => ["name = ?", groupName.downcase])
		if group != nil
			return group.uuid
		else
			return nil
		end
	end
	
	# Returns the UUID of the user name specified
	def self.lookupUserName(userName)
		user = User.find(:first, :conditions => ["username = ?", userName.downcase])
		if user != nil
			return user.uuid
		else
			return nil
		end
	end
	
	# Returns a user/group's display name or nil if the user/group
	# doesn't exist.
	def self.lookupUUID(uuid)
		user = User.find(:first, :conditions => ["uuid = ?", uuid])
		if user != nil
			return user.displayname
		else
			# lookup group name
			group = Group.find(:first, :conditions => ["uuid = ?", uuid])
			if group != nil
				return group.displayname
			else
				return nil
			end
		end
	end
	
	# Validates an authcode specified with one in the database. If it matches, it returns
	# true. Otherwise, it returns false.
	def self.verifyAuthCode(uuid, authCode)
		user = User.find(:first, :conditions => ["uuid = ? AND authcode = ?", uuid, authCode])
		if user != nil
			return true
		else
			return false
		end
	end
	
	# Takes a permissions array (see http://developer.macrodeck.com/wiki/Services:UserService)
	# and returns true if the user specified is allowed. This function returns false if the
	# user is denied. The default is to deny -- that means that if you don't explicitly
	# allow everyone in an permission array, nobody can see it!
	def self.checkPermissions(perms, uuid)
		perms.each do |perm|
			if perm[:id] != nil
				if perm[:id].downcase == uuid.downcase
					if perm[:action] == :allow
						return true
					elsif perm[:action] == :deny
						return false
					end
				elsif self.isGroup?(perm[:id])
					# if the permission is a group
					if self.doesGroupMemberExist?(perm[:id], uuid)
						if perm[:action] == :allow
							return true
						elsif perm[:action] == :deny
							return false
						end
					end
				elsif perm[:id].downcase == "everybody"
					if perm[:action] == :allow
						return true
					elsif perm[:action] == :deny
						return false
					end
				end
			else
				# perm[:id] is nil therefore something is wrong.
				# deny them.
				return false
			end
		end
		# if the user hasn't matched a rule yet, they
		# will be denied for security!
		return false
	end
end

Services.registerService(UserService)