def get_adapter
	types = ConnectionPool.adapter_types
	if types.include?(:rdflite)
    get_rdflite
	elsif types.include?(:redland)
    get_redland
	elsif types.include?(:sparql)
    get_sparql
	elsif types.include?(:yars)
    get_yars
	elsif types.include?(:jars2)
    get_jars2
	else
		raise ActiveRdfError, "no suitable adapter found for test"
	end
end

def get_read_only_adapter
	if ConnectionPool.adapter_types.include?(:sparql)
    get_sparql
  else
		raise ActiveRdfError, "no suitable read-only adapter found for test"
	end
end

# TODO make this work with a list of existing adapters, not only one
def get_different_adapter(existing_adapter)
	types = ConnectionPool.adapter_types
  if types.include?(:rdflite)
    if existing_adapter.class == RDFLite
      ConnectionPool.add :type => :rdflite, :unique => true
    else
      get_rdflite
    end
	elsif types.include?(:redland) and existing_adapter.class != RedlandAdapter
    get_rdflite
	elsif types.include?(:sparql) and existing_adapter.class != SparqlAdapter
    get_sparql
	elsif types.include?(:yars) and existing_adapter.class != YarsAdapter
    get_yars
	elsif types.include?(:jars2) and existing_adapter.class != Jars2Adapter
    get_jars2
	else
		raise ActiveRdfError, "only one adapter on this system, or no suitable adapter found for test"
	end
end

def get_all_read_adapters
	types = ConnectionPool.adapter_types
	adapters = types.collect {|type| self.send("get_#{type}") }
	adapters.select {|adapter| adapter.reads?}
end

def get_all_write_adapters
	types = ConnectionPool.adapter_types
	adapters = types.collect {|type| self.send("get_#{type}") }
	adapters.select {|adapter| adapter.writes?}
end

def get_write_adapter
	types = ConnectionPool.adapter_types
	if types.include?(:rdflite)
    get_rdflite
	elsif types.include?(:redland)
    get_redland
	elsif types.include?(:yars)
    get_yars
	elsif types.include?(:jars2)
    get_jars2
	else
		raise ActiveRdfError, "no suitable adapter found for test"
	end
end

# TODO use a list of exisiting adapters not only one
def get_different_write_adapter(existing_adapter)
	types = ConnectionPool.adapter_types
	if types.include?(:rdflite)
    if existing_adapter.class == RDFLite
      ConnectionPool.add :type => :rdflite, :unique => true
    else
      get_rdflite
    end
	elsif types.include?(:redland) and existing_adapter.class != RedlandAdapter
    get_redland
	elsif types.include?(:yars) and existing_adapter.class != YarsAdapter
    get_yars
	else
		raise ActiveRdfError, "only one write adapter on this system, or no suitable write adapter found for test"
	end
end

private
def get_sparql
  ConnectionPool.add(:type => :sparql, :url => "http://sparql.org/books",
                     :engine => :joseki, :results => :sparql_xml)
end

def get_fetching; ConnectionPool.add(:type => :fetching); end
def get_suggesting; ConnectionPool.add(:type => :suggesting); end
def get_rdflite; ConnectionPool.add(:type => :rdflite); end
def get_redland; ConnectionPool.add(:type => :redland); end
def get_yars; ConnectionPool.add(:type => :yars); end
def get_jars2; ConnectionPool.add(:type => :jars2); end
