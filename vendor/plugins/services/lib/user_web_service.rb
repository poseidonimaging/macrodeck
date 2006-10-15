# The UserWebService. Provides UserService
# functions to remote via ActionWebService.

# The UserService API definition
class UserServiceAPI < ActionWebService::API::Base
	api_method :get_auth_cookie, {
			:expects =>	[{ :userName	=> :string }],
			:returns => [:string]
		}
		
	api_method :get_auth_code, {
			:expects => [{ :authToken	=> :string }],
			:returns => [:string]
		}
end

# UserWebService. Currently provides user authentication
# facilities for remote SOAP applications.
class UserWebService < ActionWebService::Base
	web_service_api UserServiceAPI
	
	# Returns an authCookie for the specified user.
	# The authCookie is a required part of the authToken,
	# which is used to get a user's authCode. The cookie
	# serves no purpose other than as a salt, really.
	def get_auth_cookie(userName)
		uuid = UserService.lookupUserName(userName)
		return UserService.generateAuthCookie(uuid)
	end
	
	# Returns the user's authCode if the token specified is valid.
	# The token is constructed as follows:
	#
	#   token = SHA512(authCookie + ":" + SHA512(salt + ":" + password))
	#
	# If there is no salt, it will look like this:
	#
	#   token = SHA512(authCookie + ":" + SHA512(password))
	#
	# The SHA512 we expect is a "hexdigest" -- i.e. it looks like a really
	# long MD5. We also expect it in lowercase.
	#
	# The salt or lack thereof is set by the website running Services.
	def get_auth_code(authToken)
	end
end