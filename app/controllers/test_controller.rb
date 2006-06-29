class TestController < ApplicationController
	layout "default"
	def show_loaded_services
		@services = Services.getLoadedServices
	end
end
