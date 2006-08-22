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
  map.connect 'group/:groupname/blog/delete/:uuid',	:controller => 'blog', :action => 'delete'
  map.connect 'group/:groupname/blog/view/:uuid',	:controller => 'blog', :action => 'view'
  
  # Route user/:username/blog
  map.connect 'user/:username/blog',				:controller => 'blog', :action => 'index'
  map.connect 'user/:username/blog/post',			:controller => 'blog', :action => 'post'
  map.connect 'user/:username/blog/edit/:uuid',		:controller => 'blog', :action => 'edit'
  map.connect 'user/:username/blog/delete/:uuid',	:controller => 'blog', :action => 'delete'
  map.connect 'user/:username/blog/view/:uuid',		:controller => 'blog', :action => 'view'
  
  # Route group/:groupname/environment
  map.connect 'group/:groupname/environment/:envname',	:controller => 'environment', :action => 'index'
  
  # Route user/:username/environment
  map.connect 'user/:username/environment/:envname',	:controller => 'environment', :action => 'index'
  
  # Route user other stuff
  map.connect 'user/:username/home',				:controller => 'account', :action => 'home'
  map.connect 'user/:username/settings',			:controller => 'account', :action => 'settings'
  map.connect 'user/:username/environments',		:controller => 'incomplete', :action => 'environments'
  map.connect 'user/:username/shared',				:controller => 'incomplete', :action => 'shareditems'
  map.connect 'user/:username/profile',				:controller => 'incomplete', :action => 'profile'
  
  # Widget Hierarchy Routing
  map.connect 'widget/:uuid',						:controller => 'widget', :action => 'index'
  map.connect 'widget/:uuid/code.js',				:controller => 'widget', :action => 'code'
  
  # Route misc.
  map.connect 'directory',							:controller => 'incomplete', :action => 'directory'
  
  # Route / to the MacroDeck blog until pages are created.
  map.connect '', :controller => 'blog', :action => 'index', :groupname => 'macrodeck'
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
