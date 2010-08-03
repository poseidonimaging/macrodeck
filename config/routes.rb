ActionController::Routing::Routes.draw do |map|
	# The priority is based upon order of creation: first created -> highest priority.

	# Resources
	map.resources :countries do |countries|
		countries.resources :states do |states|
			states.resources :cities do |cities|
				cities.resources :events do |events|
					events.resource :wall do |wall|
						wall.resources :comments
					end
				end
				cities.resources :places do |places|
					places.resource :wall do |wall|
						wall.resources :comments
					end
				end
				cities.resource :wall do |wall|
					wall.resources :comments
				end
			end
		end
	end
	map.resources :places

  # Sparklines.
  map.sparklines 'sparklines', :controller => "sparklines"

  # Route / to the MacroDeck HomeController until we get real content
  map.connect '', :controller => 'countries', :action => 'index'
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
