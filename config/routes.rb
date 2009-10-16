ActionController::Routing::Routes.draw do |map|
	# The priority is based upon order of creation: first created -> highest priority.

	# Resources
	map.resources :countries do |countries|
		countries.resources :states do |states|
			states.resources :cities do |cities|
				cities.resources :events
				cities.resources :places
			end
		end
	end
	map.resources :places

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Facebook Events (via Places - someday we'll have our own MacroDeck Events app..)
  # calendar namespace - example: apps.facebook.com/macrodeckplaces/calendar/1234-5667-abcdef-123456435/show
  map.fbevents 'facebook/calendar/:calendar/:action/:event', :controller => "facebook_events",
  		:conditions => { :subdomain => "places" },
		:defaults => { :action => "events", :event => nil }

  # For less calendar-specific actions for events
  map.fbevents 'facebook/events/:action/', :controller => "facebook_events", :conditions => { :subdomain => "places" }

  # Facebook Search
  map.fbsearch 'facebook/search/:uuid/:action', :controller => "facebook_search",
		:conditions => { :subdomain => "places" },
		:defaults => { :uuid => nil, :action => "search" }

  # Sparklines.
  map.sparklines 'sparklines', :controller => "sparklines"

  # Facebook Home
  map.connect 'facebook', :controller => "facebook/home",
		:action => "index",
		:conditions => { :subdomain => "places" }
  map.fbhome 'facebook/home/:action', :controller => "facebook/home",
		:conditions	=> { :subdomain => "places" },
		:defaults	=> { :action => "index" }

  # Facebook Places
  map.fbplaces 'facebook/:action/:country/:state/:city/:place', :controller => "facebook_places",
		:conditions => { :subdomain => "places" },
		:defaults => { :action => "browse", :country => "all", :state => nil, :city => nil, :place => nil }
  
  # Places
  map.places '', :controller => "places", :conditions => { :subdomain => "places" }
  map.places ':action/:country/:state/:city/:place', :controller => 'places',
	  :conditions => { :subdomain => "places" },
	  :defaults => { :action => "index", :country => "all", :state => nil, :city => nil, :place => nil }

  # Route / to the MacroDeck HomeController until we get real content
  map.connect '', :controller => 'home', :action => 'index'
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
