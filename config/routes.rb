ActionController::Routing::Routes.draw do |map|
  map.resources :factoids
  map.resources :facilities

  map.connect '/l/:state/:city', 
        :controller => 'locations',
        :action => 'show'

  map.connect '/l/:zip',
        :controller => 'locations',
        :action => 'zip',
        :zip => /\d{5}/


  map.connect '/e/:uri', 
        :controller => 'entities',
        :action => 'show',
        :uri => /.*\.rdf/,
        :format => 'rdf'

  map.connect '/e/:uri', 
        :controller => 'entities',
        :action => 'show',
        :uri => /.*/

  map.resources :chemicals
  map.root :controller => 'locations'
end
