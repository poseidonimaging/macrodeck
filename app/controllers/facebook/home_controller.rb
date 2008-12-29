class Facebook::HomeController < ApplicationController
	before_filter :require_facebook_login
	before_filter :initialize_facebook_user
	before_filter :setup_breadcrumbs

	layout "facebook/home"

	def index
	end
end
