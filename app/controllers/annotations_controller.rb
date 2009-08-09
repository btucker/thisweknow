# ui:attribute
# ui:hasMany
# ui:belongsTo

class AnnotationsController < ApplicationController
  before_filter :digest_authenticate
  before_filter :scrub_whitespace

  def index
    res = Sparql.execute("SELECT ?o WHERE { ?s rdf:type ?o }", :ruby)
    @classes = res.map { |r| r[:o] }.compact
  end

  def show
    @example = Sparql.execute("SELECT ?s ?p ?o WHERE { ?s rdf:type <#{params[:uri]}> . ?s ?p ?o } LIMIT 50", :ruby)
    @attributes = Sparql.execute("SELECT ?p WHERE { <#{params[:uri]}> ui:attribute ?p }", :ruby).map{|a| a[:p]}
    @belongs_to = Sparql.execute("SELECT ?p WHERE { <#{params[:uri]}> ui:belongsTo ?p }", :ruby).map{|a| a[:p]}
    @has_many = []
    #@has_many = Sparql.execute("SELECT ?c ?p WHERE { ?c ui:belongsTo ?p . ?obj rdf:type ?c . ?obj ?p ?obj2 . ?obj2 rdf:type <#{params[:uri]}> }", :ruby)
  end

  def add_annotation
    Sparql.execute("INSERT INTO <ui> { <#{params[:uri]}> ui:#{params[:t]} <#{params[:p]}> }")
    redirect_to :action => 'show', :uri => params[:uri]
  end

  def remove_annotation
    Sparql.execute("DELETE FROM <ui> { <#{params[:uri]}> ui:#{params[:t]} <#{params[:p]}> }")
    redirect_to :action => 'show', :uri => params[:uri]
  end

  def scrub_whitespace
    [:uri, :t, :p].each do |p|
      params[p].gsub!(/\s+/, '') if params[p]
    end
  end

end
