ActionController::Routing::Routes.draw do |map|
  map.resources :factoids
  map.resources :facilities

  map.connect '/l/search',
        :controller => 'locations',
        :action => 'search'

  map.connect '/l/:state/:city', 
        :controller => 'locations',
        :action => 'show'

  map.connect '/l/:state/:city/factoids/:id',
       :controller => 'locations',
       :action => 'factoid'

  map.connect '/l/:q',
        :controller => 'locations',
        :action => 'search',
        :q => /\d{5}/

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
  map.connect '/:controller/:action', :controller => /annotations|pages/
  map.root :controller => 'locations'
end
