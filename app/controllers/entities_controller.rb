class EntitiesController < ApplicationController
  NAMESPACES = {
    'rdf'  => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    'rdfs' => "http://www.w3.org/2000/01/rdf-schema#"
  }
  def show
    @uri = params[:uri] #= "http://www.data.gov/data/Company_7332d5d28a6626f50242a12bf79de077"
    @uri.sub!(/\.rdf$/,'')

    xml = Sparql.describe(@uri)

    respond_to do |f|
      f.html {
        @label = xml.search("//rdf:Description[@rdf:about='#{@uri}']/rdfs:label", NAMESPACES).first.content
        @belongs_to = xml.search("//rdf:Description[@rdf:about='#{@uri}']/*[@rdf:resource]", NAMESPACES).select do |e|
          e.name != 'type'
        end
        @belongs_to.map! do |e|
          [ 
            uri = e.get_attribute("resource"),
            e.name.underscore.humanize,
            (xml.search("//rdf:Description[@rdf:about='#{uri}']/rdfs:label", NAMESPACES).first and
              xml.search("//rdf:Description[@rdf:about='#{uri}']/rdfs:label", NAMESPACES).first.content
            ) 
          ]
        end
      }
      f.rdf {
        render :rdf => xml
      }
    end
  end
end
