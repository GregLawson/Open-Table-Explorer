require "active_record"
require "arConnection.rb"
#desc 'Create YAML test fixtures from data in an existing database.  

#Defaults to development database.  Set RAILS_ENV to override.''

#task :extract_fixtures => :environment do
def scaffold (table_name)
	#~ Global::log.info("table_name=#{table_name}")
	#~ Global::log.info("in scaffold table_name=#{table_name}")
	rails="script/generate scaffold #{table_name} "
	ActiveRecord::Base.connection.columns(table_name).each do  |col|
		#~ puts "col=#{col.inspect}"
		#~ puts "col.klass=#{col.klass}"
		#~ puts "col.type=#{col.type}"
		rails="#{rails} #{col.name}:#{col.type}"
		#puts rails
	end
	return rails
end #def
def db2scaffold
  skip_tables = ["schema_info","tedprimaries","weathers"]
#  ActiveRecord::Base.establish_connection
  (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
 #   puts table_name,ActiveRecord::Base.connection.columns(table_name).inspect
	puts scaffold(table_name)
 end #each table_name
end #def
db2scaffold
