ActionController::Routing::Routes.draw do |map|
	# The priority is based upon order of creation: first created -> highest priority.

	# Resources
	map.resources :countries do |countries|
		countries.resources :regions do |regions|
			regions.resources :localities do |localities|
				localities.resources :events
				localities.resources :places do |places|
					places.resources :events
				end
			end
		end
	end
	map.resources :places

  # Sparklines.
  map.sparklines 'sparklines', :controller => "sparklines"

  # Route / to Austin happenings.
  map.connect '', :controller => 'events', :action => 'index', :country_id => "875de01b-edb9-47a4-aabc-7acd97ecde43", :region_id => "ea46e21f-889c-4960-b0eb-3cf65a093a1c", :locality_id => "bfff92eb-d35c-4df3-ae8f-01e68c3f8fc6"
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
