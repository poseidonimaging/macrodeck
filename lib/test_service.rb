class TestService < BaseService
	@serviceID = "com.macrodeck.TestService"
	@serviceName = "TestService"	
	@serviceVersionMajor = 1
	@serviceVersionMinor = 0	
	@serviceVersionRevision = 20060622
	@serviceUUID = "9de63d03-9a05-4514-9e8e-c829b090263c"
	
	def self.test()
		return "TestService.test() successful."
	end
end

Services.registerService(TestService)