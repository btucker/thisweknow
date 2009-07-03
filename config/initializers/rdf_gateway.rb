require 'activerdf_sparql/sparql'
require 'activerdf_sparql/sparql_result_parser'

$activerdf_without_xsdtype = true # makes find_by_* queries work

class Query2SPARQL
  def self.translate(query, engine=nil)
    str = ""
    if query.select?
      distinct = query.distinct? ? "DISTINCT " : ""
			select_clauses = query.select_clauses.collect{|s| construct_clause(s)}

      str << "SELECT #{distinct}#{select_clauses.join(' ')} "
      str << "FROM <tri> "
      str << "WHERE { #{where_clauses(query)} #{filter_clauses(query)}} "
      str << "LIMIT #{query.limits} " if query.limits
      str << "OFFSET #{query.offsets} " if query.offsets
    elsif query.ask?
      str << "ASK { #{where_clauses(query)} } "
    end
    
    return str
  end
end

ConnectionPool.add_data_source(:type => :sparql, :results => :sparql_xml, :engine => :yars2, :url => 'http://206.192.70.249/data.gov/sparql.aspx')
Namespace.register :tri, 'http://www.data.gov/tri/'
ObjectManager.construct_classes
