# ui:attribute
# ui:hasMany
# ui:belongsTo

class AnnotationsController < ApplicationController
  def index
    res = Sparql.execute("SELECT ?o ?label WHERE { ?s rdf:type ?o }")
    @classes = res.search("result binding uri").map(&:content)
  end

  def show
    @example = Sparql.execute("SELECT ?s ?p ?o WHERE { ?s rdf:type <#{params[:uri]}> . ?s ?p ?o } LIMIT 50", :ruby)
    @attributes = Sparql.execute("SELECT ?p WHERE { <#{params[:uri]}> ui:attribute ?p }", :ruby).map{|a| a[:p]}
    @belongs_to = Sparql.execute("SELECT ?p WHERE { <#{params[:uri]}> ui:belongsTo ?p }", :ruby).map{|a| a[:p]}
    @has_many = Sparql.execute("SELECT ?c ?p WHERE { ?c ui:belongsTo ?p . ?obj rdf:type ?c . ?obj ?p ?obj2 . ?obj2 rdf:type <#{params[:uri]}> }", :ruby)
  end
end
