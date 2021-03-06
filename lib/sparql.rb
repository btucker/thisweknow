require 'net/http'
require 'uri'

class Sparql 
  def self.execute(query, format = :xml)
    query = insert_from_clause(query)
    Rails.logger.info "[SPARQL] #{prefixes + query}"
    res = Net::HTTP.post_form(URI.parse('http://206.192.70.249/data.gov/sparql.aspx'),
                              {'query' => prefixes + query})
    xml = Nokogiri::XML(res.body)
    if format == :xml
      xml
    elsif format == :ruby
      xml.search("result").map do |r|
        returning({}) do |res|
          r.search("binding").each do |b|
            res[b.get_attribute('name').to_sym] = b.search("uri,literal").map(&:content).first
          end
        end
      end
    end
  end

  def self.describe(entity, graph='data')
    execute(describe_prefix + "DESCRIBE <#{entity}>" + graphs)
  end

  def self.insert_from_clause(query)
    if query =~ /\bfrom\b/i
      query
    else
      query.sub(/\bWHERE\b/i, graphs + 'WHERE') 
    end
  end

  def self.graphs
    %Q{ FROM <data> FROM <census> FROM <census_data> FROM <govtrack> FROM <ui> FROM <lobbyists> FROM <cancer> }
  end

  def self.prefixes
    %Q{
    PREFIX o: <http://www.data.gov/ontology#>
    PREFIX ui: <http://www.thisweknow.org/ui#>
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX dc: <http://purl.org/dc/elements/1.1/>
    PREFIX dcterms: <http://purl.org/dc/terms/>
    PREFIX owl: <http://www.w3.org/2002/07/owl#>
    PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
    PREFIX samp: <http://www.rdfabout.com/rdf/schema/uscensus/details/samp/>
    PREFIX foaf: <http://xmlns.com/foaf/0.1/>
    } 
  end

  def self.describe_prefix
    %Q{
     rulebase (
       # special rule to look for all marked predicates for the
       # class of the entity (?r) and recursively describe all
       # included references.
       SELECT ?s ?p ?o ?r ?d WHERE {
                        ?r rdf:type ?class.
                        ?class ui:belongsTo ?ref.
                        ?r ?ref ?included.
                               descriptionDepth(?s, ?p, ?o, ?included, ?d -
1).
                               Filter(?d > 0).
               } as <descriptionDepth>

         # make sure we get labels of any entities we refer to (if they exist)
         SELECT ?s rdfs:label ?o ?r ?d where {?r ?x ?s. ?s rdfs:label ?o} as <descriptionDepth>

         # we want all immediate statements
         SELECT ?s ?p ?o ?r ?d where {?s ?p ?o. filter(?r=?s)} as <descriptionDepth>

         # tie the descriptionDepth rule to the description rule that describe uses
         SELECT ?s ?p ?o ?r where {descriptionDepth(?s, ?p, ?o, ?r, 2)} as <description>
     )
    }
  end
end
