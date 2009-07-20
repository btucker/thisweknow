ActionController::Routing::Routes.draw do |map|
  map.resources :factoids
  map.resources :zips
  map.resources :facilities

  map.resources :entities
  map.resources :chemicals
  map.root :controller => 'zips'
end
