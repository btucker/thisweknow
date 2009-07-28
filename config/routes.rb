ActionController::Routing::Routes.draw do |map|
  map.resources :factoids
  map.resources :zips
  map.resources :facilities

  map.connect '/e/:uri', 
        :controller => 'entities',
        :action => 'show',
        :uri => /.*/
  map.resources :chemicals
  map.root :controller => 'zips'
end
