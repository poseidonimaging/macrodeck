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
  
  # Route group/:groupname/blog
  map.connect 'group/:groupname/blog', :controller => 'blog', :action => 'index'
  
  # Route user/:username/blog
  map.connect 'user/:username/blog', :controller => 'blog', :action => 'index'
  
  # Route user/:username/home
  map.connect 'user/:username/home', :controller => 'account', :action => 'home'
  
  # Route / to the MacroDeck blog until pages are created.
  map.connect '', :controller => 'blog', :action => 'index', :groupname => 'macrodeck'
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
