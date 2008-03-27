ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Facebook Events (via Places - someday we'll have our own MacroDeck Events app..)
  # Place-specific event create URL
  map.fbevents_create_from_places 'facebook/view/:country/:state/:city/:place/create_event', :controller => "facebook_events",
  		:action => "create_from_places",
  		:conditions => { :subdomain => "places" }

  # calendar namespace - example: apps.facebook.com/macrodeckplaces/calendar/1234-5667-abcdef-123456435/show
  map.fbevents 'facebook/calendar/:calendar/:action/:event', :controller => "facebook_events",
  		:conditions => { :subdomain => "places" },
		:defaults => { :action => "events", :event => nil }

  # Facebook Places
  map.fbplaces 'facebook', :controller => "facebook_places",
		:action => "welcome", :default => true, :country => nil, :state => nil, :city => nil, :place => nil,
		:conditions => { :subdomain => "places" }

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
