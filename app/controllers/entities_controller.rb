class EntitiesController < ApplicationController
  NAMESPACES = {
    'rdf'  => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    'rdfs' => "http://www.w3.org/2000/01/rdf-schema#"
  }

  def attributes_for(uri)
    attributes = {}
    @xml.search("//rdf:Description[@rdf:about='#{uri}']/rdf:type", NAMESPACES).map{|e| e.get_attribute('resource')}.compact.each do |type|
      if @annotations[type] and @annotations[type][:attribute]
        @annotations[type][:attribute].each do |at|
          at.match(/(.*[#\/])([^#\/]+)$/)
          attributes[$2] = @xml.search("//rdf:Description[@rdf:about='#{uri}']/nsx:#{$2}", 
                      NAMESPACES.merge('nsx' => $1)).map(&:content)
        end
      end
    end
    attributes
  end

  def belongs_to_for(uri, seen=[])
    if seen.include? uri
      return {}
    else
      seen << uri
    end
    belongs_tos = {}
    @xml.search("//rdf:Description[@rdf:about='#{uri}']/rdf:type", NAMESPACES).map{|e| e.get_attribute('resource')}.compact.each do |type|
      if @annotations[type] and @annotations[type][:belongs_to]
        @annotations[type][:belongs_to].each do |at|
          at.match(/(.*[#\/])([^#\/]+)$/)
          belongs_tos[$2] = @xml.search("//rdf:Description[@rdf:about='#{uri}']/nsx:#{$2}", 
                      NAMESPACES.merge('nsx' => $1)).map{|e| e.get_attribute('resource')}.map {|u| belongs_to_for(u,seen).merge(:uri => u)}
        end
      end
    end
    belongs_tos.merge(attributes_for(uri))
  end

  def flatten(hash, top=true)
    if hash.is_a? Hash
      hash.each do |k,v|
        if v.is_a? Array
          if v and v.size == 1 and v.first.is_a? Hash
            hash.delete(k)
            hash.merge!(flatten(v.first))
          elsif v and v.size > 1 and v.first.is_a? Hash  
            # collection of things
            flatten(v)
          elsif v.blank?
            hash.delete(k)
          end
        end
      end
    elsif hash.is_a? Array
      hash.map!{|e| flatten(e) }
    end
    hash
  end

  def show
    @uri = params[:uri] #= "http://www.data.gov/data/Company_7332d5d28a6626f50242a12bf79de077"
    @uri.sub!(/\.rdf$/,'')

    @xml = Sparql.describe(@uri)

    @label = @xml.search("//rdf:Description[@rdf:about='#{@uri}']/rdfs:label", NAMESPACES).map(&:content).map(&:titleize).first || @uri

    # get all the types 
    # get all the belongs_tos & attributes for each type
    @annotations = {}
    types = @xml.search("//rdf:type").map{|e| e.get_attribute('resource')}.compact.uniq
    res = Sparql.execute("SELECT ?s ?t ?p WHERE { ?s ?t ?p . FILTER(?t=ui:attribute || ?t=ui:belongsTo) .
                           FILTER( #{types.map{|uri| "?s=<#{uri}>"}.join(" || ") } )}", :ruby)
    res.group_by { |r| r[:s] }.each do |klass, annotations|
      @annotations[klass] = {
        :attribute => annotations.select { |r| r[:t] =~ /attribute$/ }.map { |r| r[:p] },
        :belongs_to => annotations.select { |r| r[:t] =~ /belongsTo$/ }.map { |r| r[:p] }
      }
    end
    @entity = belongs_to_for(@uri)

    respond_to do |f|
      f.html 
      f.json {
        render :json => @entity
      }
      f.rdf {
        render :text => @xml
      }
    end
  end
end
