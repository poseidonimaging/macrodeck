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

  # Facebook Places
  map.fbplaces 'facebook', :controller => "facebook_places",
		:action => "browse", :country => "summary",
		:conditions => { :subdomain => "places" },
		:defaults => { :state => nil, :city => nil, :place => nil }

  map.fbplaces 'facebook/:action/:country/:state/:city/:place', :controller => "facebook_places",
		:conditions => { :subdomain => "places" },
		:defaults => { :action => "browse", :country => "us", :state => nil, :city => nil, :place => nil }
  
  # Places
  map.places '', :controller => "places", :conditions => { :subdomain => "places" }
  map.places ':action/:country/:state/:city/:place', :controller => 'places',
	  :conditions => { :subdomain => "places" },
	  :defaults => { :action => "index", :country => "us", :state => nil, :city => nil, :place => nil }

  # Route / to the MacroDeck Places homepage until we get a real one.
  map.connect '', :controller => 'home', :action => 'index'
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
