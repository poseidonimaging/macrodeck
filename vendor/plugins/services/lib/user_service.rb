# This service provides user support
# across MacroDeck.

class UserService < BaseService
	@serviceAuthor = "Keith Gable <ziggy@ignition-project.com>"
	@serviceID = "com.macrodeck.UserService"
	@serviceName = "UserService"	
	@serviceVersionMajor = 1
	@serviceVersionMinor = 0	
	@serviceVersionRevision = 20060704
	@serviceUUID = "8d6e8d29-55b0-4d74-bf71-84b2d653ba1f"
	
	def self.createUser(name, password, passHint, secretQuestion, secretAnswer, name, displayName, dob)
	end
end

Services.registerService(UserService)