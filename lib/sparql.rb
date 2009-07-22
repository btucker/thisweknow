require 'open-uri'

class Sparql 
  def self.execute(query)
    Rails.logger.info "[SPARQL] #{query}"
    Nokogiri::XML(open(URI.encode("http://206.192.70.249/data.gov/sparql.aspx?query=#{prefixes + query}")))
  end

  def self.prefixes
    %Q{
      PREFIX o: <http://www.data.gov/ontology#>
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX owl: <http://www.w3.org/2002/07/owl#>
    } 
  end
end
