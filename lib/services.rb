# This class contains the core of the Services framework. It has no instance methods and should be
# accessed using its class methods only. See the comments below each function for information on how
# they work.
#
# You will probably be interested in Services and BaseService.

require "base_service"

class Services	
	@@loadedServices = Array.new
	
	# Starts a service from fileName.
	# Returns true if successful, false if service could not be loaded, and nil if some other error occured.
	def Services.startService(fileName)
		begin
			require fileName
			return true
		rescue LoadError
			return false
		rescue StandardError
			return nil # Return nil if there was some other error
		end
		
	end
	
	# Used by the services themselves to register themselves with Services.
	def Services.registerService(serviceObj)
		name = serviceObj.serviceName
		versionMajor = serviceObj.serviceVersionMajor
		versionMinor = serviceObj.serviceVersionMinor
		versionRevision = serviceObj.serviceVersionRevision
		uuid = serviceObj.serviceUUID
		id = serviceObj.serviceID
		servicehash = Hash.new
		servicehash = { :name => name, :version => { :major => versionMajor, :minor => versionMinor, :revision => versionRevision }, :uuid => uuid, :id => id, :class => serviceObj }
		@@loadedServices = @@loadedServices << servicehash
		return nil
	end

	# Returns true if the service specified is started. Otherwise, returns false.
	# Expects a UUID or a hash. If you specify a hash, it should look like this:
	#
	# :id => "com.macrodeck.WhateverService"
	# 
	# But the symbol can be either :id, :uuid, or :name.
	def Services.serviceStarted?(serviceId)
		if serviceId.class == Hash
			# figure out what to look for
			if serviceId[:uuid] != nil
				search = serviceId[:uuid]
				searchType = :uuid
			elsif serviceId[:id] != nil
				search = serviceId[:id]
				searchType = :id
			elsif serviceId[:name] != nil
				search = serviceId[:name]
				searchType = :name
			end
		else
			# UUID specified (we hope?)
			search = serviceId
			searchType = :uuid
		end
		# Now iterate!
		foundService = false
		@@loadedServices.each do |service|
			if searchType == :uuid
				# lowercase the UUID, since we may have uppercase
				# UUIDs for some reason.
				if service[:uuid].downcase == search.downcase
					foundService = true
				end
			elsif searchType == :id
				if service[:id] == search
					foundService = true
				end
			elsif searchType == :name
				if service[:name] == search
					foundService = true
				end
			end
		end
		return foundService
	end
	
	# Prints out the loaded services in a human-readable format. *NOTE*: will likely be replaced in the future!
	def Services.printLoadedServices()
		print "MacroDeck Services\n"
		print "==================\n"
		print "\n"
		@@loadedServices.each do |service|
			print "Name: " + service[:name] + "\n"
			print "UUID: " + service[:uuid] + "\n"
			print "ID  : " + service[:id] + "\n"
			print "Ver : " + service[:version][:major].to_s + "." + service[:version][:minor].to_s + "." + service[:version][:revision].to_s +  "\n"
			print "\n"
		end
		return nil
	end
end