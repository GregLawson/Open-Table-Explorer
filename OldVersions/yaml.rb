require "active_record"
require "arConnection.rb"
#desc 'Create YAML test fixtures from data in an existing database.  

#Defaults to development database.  Set RAILS_ENV to override.''

#task :extract_fixtures => :environment do
def db2yaml
  limit=100
  sql  = "SELECT * FROM %s LIMIT #{limit}"
  countSql  = "SELECT COUNT(*) FROM %s"
  skip_tables = ["schema_info","tedprimaries","weathers"]
#  ActiveRecord::Base.establish_connection
  (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
    i = "000"
    count=ActiveRecord::Base.connection.select_all(countSql % table_name)
    puts "count.inspect=#{count.inspect}"
    puts "count[0].class=#{count[0].class}"
    puts "count[0].inspect=#{count[0].inspect}"
    puts "count[0].keys.inspect=#{count[0].keys.inspect}"
    puts "count[0].values.inspect=#{count[0].values.inspect}"
    puts "count[0].values[0].inspect=#{count[0].values[0].inspect}"
    count=count[0].values[0].to_i
    puts "#{table_name} has #{count} records."
    if  count>limit then
	puts "truncated to #{limit} records."
	end
    	File.open("rails/test/fixtures/#{table_name}.yml", 'w') do |file|
      		data = ActiveRecord::Base.connection.select_all(sql % table_name)
#      if data.length<100000 then
	 file.write data.inject({}) { |hash, record|
        hash["#{table_name}_#{i.succ!}"] = record
        hash
      }.to_yaml
#	end
    end
  end
end
db2yaml
