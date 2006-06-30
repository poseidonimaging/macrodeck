class TestController < ApplicationController
	layout "default"
	def start_service
		Services.startService @params[:service]
		redirect_to :action => "show_loaded_services"
	end
	def show_loaded_services
		@services = Services.getLoadedServices
	end
end
