$activerdf_without_xsdtype = true # makes find_by_* queries work
ConnectionPool.add_data_source(:type => :sparql, :results => :sparql_xml, :engine => :yars2, :url => 'http://206.192.70.249/data.gov/sparql.aspx')
Namespace.register :tri, 'http://www.data.gov/tri/'
ObjectManager.construct_classes
