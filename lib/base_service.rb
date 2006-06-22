class BaseService
	# MacroDeck Services
	# BaseService - This service provides the methods common to all services.
	
	@serviceID = "com.macrodeck.BaseService"	
	@serviceName = "BaseService"	
	@serviceVersionMajor = 0
	@serviceVersionMinor = 0
	@serviceVersionRevision = 0
	@serviceUUID = "78d71960-3387-4ea6-84ca-399d2f880469"

	# Service versioning functions.
	
	def self.serviceID
		@serviceID
	end

	def self.serviceName
		@serviceName
	end
	
	def self.serviceVersionMajor
		@serviceVersionMajor
	end
	
	def self.serviceVersionMinor
		@serviceVersionMinor
	end
	
	def self.serviceVersionRevision
		@serviceVersionRevision
	end
	
	def self.serviceUUID
		@serviceUUID
	end
	
end