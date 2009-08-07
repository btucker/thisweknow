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
        @label = xml.search("//rdf:Description[@rdf:about='#{@uri}']/rdfs:label", NAMESPACES).map(&:content).map(&:titleize).first || @uri
        @belongs_to = xml.search("//rdf:Description[@rdf:about='#{@uri}']/*[@rdf:resource]", NAMESPACES).select do |e|
          e.name != 'type'
        end
        @belongs_to.map! do |e|
          { 
            :uri => uri = e.get_attribute("resource"),
            :p => e.name.underscore.humanize,
            :type => xml.search("//rdf:Description[@rdf:about='#{uri}']/rdf:type", NAMESPACES).map{|e| e.get_attribute('resource')},
            :label => xml.search("//rdf:Description[@rdf:about='#{uri}']/rdfs:label", NAMESPACES).map(&:content).first
          }
        end
      }
      f.rdf {
        render :text => xml
      }
    end
  end
end
