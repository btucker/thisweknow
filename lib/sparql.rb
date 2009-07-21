require 'open-uri'

class Sparql 
  def self.execute(query)
    Rails.logger.info "[SPARQL] #{query}"
    Nokogiri::XML(open(URI.encode("http://206.192.70.249/data.gov/sparql.aspx?query=#{query}")))
  end
end