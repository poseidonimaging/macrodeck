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
  map.connect 'group/:groupname/blog',				:controller => 'blog', :action => 'index'
  map.connect 'group/:groupname/blog/post',			:controller => 'blog', :action => 'post'
  map.connect 'group/:groupname/blog/edit/:uuid',	:controller => 'blog', :action => 'edit'
  
  # Route user/:username/blog
  map.connect 'user/:username/blog',				:controller => 'blog', :action => 'index'
  map.connect 'user/:username/blog/post',			:controller => 'blog', :action => 'post'
  map.connect 'user/:username/blog/edit/:uuid',		:controller => 'blog', :action => 'edit'
  
  # Route user home and settings
  map.connect 'user/:username/home',				:controller => 'account', :action => 'home'
  map.connect 'user/:username/settings',			:controller => 'account', :action => 'settings'
  
  # Route / to the MacroDeck blog until pages are created.
  map.connect '', :controller => 'blog', :action => 'index', :groupname => 'macrodeck'
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
