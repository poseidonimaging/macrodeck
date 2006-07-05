# This service provides user support across MacroDeck.
# This service requires UUIDService to work correctly.
# It also depends on the existance of Rails, or at
# least ActiveRecord.

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
			user.password = password
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
end

Services.registerService(UserService)