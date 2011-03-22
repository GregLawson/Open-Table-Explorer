class TableSpec < ActiveRecord::Base
has_many :acquisition_stream_specs
belongs_to :frequency
include Global
def logical_primary_key
	return model_class_name
end #def
def table2yaml(table_name)
	primaryKeyValue=logical_primary_key
#	primaryKey.to_s
	i = "000"
	limit=100
	sql  = "SELECT * FROM %s LIMIT #{limit}"
    	File.open("#{table_name}.yml.gen", 'w') do |file|
      		data = ActiveRecord::Base.connection.select_all(sql % table_name)
		puts "data.inspect=#{data.inspect}"
		 file.write data.inject({}) { |hash, record|
#			puts "#{primaryKeyExpression}.inspect=#{primaryKeyValue.inspect}"
			record.delete('id') 
			
			puts "record.inspect=#{record.inspect}"
			hash[primaryKeyValue] = record
			hash
		}.to_yaml
	end# file open
end #def
def self.db2yaml
	skip_tables = ["schema_info","tedprimaries","weathers"]
  (	ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
		table2yaml(table_name)
	end #each
end #def

end
