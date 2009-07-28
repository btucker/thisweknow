require 'open-uri'

class Sparql 
  def self.execute(query)
    Rails.logger.info "[SPARQL] #{prefixes + query}"
    Nokogiri::XML(open(URI.encode("http://206.192.70.249/data.gov/sparql.aspx?query=#{prefixes + query}")))
  end

  def self.describe(entity, graph='data')
    execute(describe_prefix + "DESCRIBE <#{entity}> FROM <#{graph}>")
  end

  def self.prefixes
    %Q{
      PREFIX o: <http://www.data.gov/ontology#>
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX owl: <http://www.w3.org/2002/07/owl#>
    } 
  end

  def self.describe_prefix
    %Q{
      rulebase (
        select ?s ?p ?o ?r where 
        {?s ?p ?o. filter(?s=?r)} as <description>
            
        # special rule to look for all marked predicates for the
        # class of the entity (?r) and recursively describe all
        # included references.
        
        select ?s ?p ?o ?r where {
                         ?r rdf:type ?class.
                         ?class o:includedReference ?ref.
                         ?r ?ref ?included.
                         <description>(?s, ?p, ?o, ?included).
        }as <description>
      )
    }
  end
end
