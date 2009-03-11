ActionController::Routing::Routes.draw do |map|
  # map.resources :devices
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "home"
  map.connect 'logout', :controller => 'login', :action => 'logout'
  map.connect 'admin/accounts/:action', :controller => 'admin/accounts'
  map.connect 'admin/users/:action', :controller => 'admin/users'
  map.connect 'admin/devices/:action', :controller => 'admin/devices'
  map.connect 'admin/device_profiles/:action', :controller => 'admin/device_profiles'
  map.connect 'admin/transaction/:action', :controller => 'admin/transaction'
  map.connect 'admin/translation/:action', :controller => 'admin/translation'
  map.connect 'enfora/device/:action', :controller => 'enfora/device'
  map.connect 'enfora/command_request/:action', :controller => 'enfora/command_request'
  map.connect 'simcom/device/:action', :controller => 'simcom/device'
  map.connect 'simcom/command_request/:action', :controller => 'simcom/command_request'
  map.geofence 'geofence', :controller=>'geofence', :action=>'index'
  map.new 'geofence/new', :controller=>'geofence', :action=>'new'
  map.edit 'geofence/edit/:id', :controller=>'geofence', :action=>'edit', :id=>/\d+/    
  map.delete 'geofence/delete/:id', :controller=>'geofence', :action=>'delete', :id=>/\d+/    
  map.detail 'geofence/detail/:id', :controller=>'geofence', :action=>'detail', :id=>/\d+/
  map.view 'geofence/view', :controller=>'geofence', :action=>'view'
    
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
   
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
#  map.connect '*path', :controller=>'home'
end