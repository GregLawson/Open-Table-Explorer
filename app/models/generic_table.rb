module Generic_Table
#include Structure_From_Data
def Generic_Table.activeRecordTableNotCreatedYet?(obj)
	return (obj.class.inspect=~/^[a-zA-Z0-9_]+\(Table doesn\'t exist\)/)==0
end #def
def updates(variableHashes)
#	Global::log.info("variableHashes.inspect=#{variableHashes.inspect}")
	variableHash={} # merge into single hash
	variableHashes.each do |vhs|
		vhs.each do |vh|
			variableHash.merge(vh)
		end #each
	end #each
#	Global::log.info("variableHash.inspect=#{variableHash.inspect}")
	if exists?(variableHash) then
		@@log.debug("record already exists")
	else
		row=self.new
#		Global::log.info( "variableHash['khhr_observation_time_rfc822']=#{variableHash['khhr_observation_time_rfc822']}")
		reportNull(variableHash)
		row.update_attributes(variableHash)
		now=Time.new
		if row.has_attribute?('created_at') then
			row.update_attribute("created_at",now)
		end #if
		if row.has_attribute?('updated_at') then
			row.update_attribute("updated_at",now)
		end #if
		#update_attribute("id","NULL") 
	end # if else
	
end #def

def process(acquisitionData)
	acqClasses=Generic_Acquisitions.parse_classes(m)
	acqClasses.each collect do |ac|
		variableHashes=ac.parse(acquisitionData)
	end #each
	row.updates(variableHashes)
	row.save
	return row
end
def log
begin
	sample
	wait
end until false
end # method log
def monitor(keys) # update continously
#	Global::log.info("in monitor self.name=#{self.name}")
	whoAmI
	#generic_acquisitions
	begin
		acquisitionData=acquire
		if self.acquisitionsUpdated?(acquisitionData) then
			row=find_or_initialize(keys)
			row.process(acquisitionData)
			row.printLog
		else
#			Global::log.info(acquisitionData)
		end
	
		wait
	end until false
end # method monitor
def sample
	@acqClasses=Generic_Acquisitions.parse_classes(m)
	@acqClasses.each collect do |ac|
		@acquisitionData=acquire
	end #collect
	@acquisitionData.each do |ad|
		if acquisitionUpdated?(ad) then
			row=self.create
			row=process(ad)
			row.printLog
		else
			puts ad
		end
	end
end
def updateMaxTypeNum(maxTypeNums)
	adaptiveAcquisition
	values= getValues
	values.each_index do |i|
		maxTypeNums[i]=[Import_Column.firstMatch(values[i]),maxTypeNums.fetch(i,-1)].max
	end
	return   maxTypeNums
end #def
def column_Definitions
	adaptiveAcquisition
	names=getNames
#	Global::log.debug("names=#{names}")
	typeNums=[] # make it array, so array functons can be used
        numSamples=0
        begin
        	typeNums=updateMaxTypeNum(typeNums)
        	numSamples = numSamples+1
        end until streamEnd or numSamples>10
	@sqlTypes=[]
	ret=[]
	names.each_index do |i| 
		@sqlTypes.push(Import_Column.row2ImportType(typeNums[i]))
#		Global::log.info("#{names[i]} #{@sqlTypes[i]} \"#{@sqlValues[i]}\" #{typeNums[i]}")
		ret.push([names[i],@sqlTypes[i]])
#		Global::log.info("ret=#{ret}")
	end
#	Global::log.info("ret=#{ret}")
	return ret
end
def adaptiveAcquisition
	notModifieds=0
	done=false
	begin
		@acquisitionData=acquire 
		if acquisitionsUpdated? then
			done=true
		else
			notModifieds=notModifieds+1
			if notModifieds.modulo(10)==0 then
#				Global::log.info("notModifieds=#{notModifieds}")
#				Global::log.info("@acquisitionData=#{@acquisitionData}")
			else
#				Global::log.info("not updated")	
			end
		end	
		#sleep self[:interval]
		wait
	end until done
#	Global::log.info("notModifieds=#{notModifieds}")
	return @acquisitionData
end 

def find_or_initialize(findCriteria)
	records=find(:all,findCriteria)
	if records.empty? then
		ret= self.new(findCriteria)
		return ret
	elsif records.size==1 then
		return records[0]
	else
		@@log.debug("criteria not unque; records=#{records.inspect}")
		raise 
	end
end
def display(exp)
 puts "#{exp}="
 puts "#{eval(exp)}"
 puts "#{exp}=#{eval(exp)}"
end
def singularTableName2
#	Global::log.info("in singularTableName self.class=#{self.class}")
#	Global::log.info("in singularTableName self.to_s=#{self.to_s}")
	return self.to_s.chop
end # def
def Require_Table(tableName=self.to_s)
#	Global::log.info("in Require_Table self.class=#{self.class}")
#	Global::log.info("in Require_Table self.to_s=#{self.to_s}")
#	Global::log.info("in Require_Table tableName=#{tableName}")
	if pg_table_exists? then
		#return new
	else
		puts "Table #{tableName} does not exist. Enter following command in rails to create:"
		#puts Generic_Columns.scaffold(Generic_Columns.column_Definitions)
		puts scaffold(self.column_Definitions)
#		puts scaffold(self.column_Definitions)
	end
end
def scaffold (columnDefs)
#	Global::log.info("singularTableName=#{singularTableName}")
#	Global::log.info("in scaffold singularTableName=#{singularTableName}")
	rails="script/generate scaffold #{singularTableName} "
	columnDefs.each do  |col|
		rails="#{rails} #{col[0]}:#{col[1]}"
		#puts rails
	end
	return rails
end
def singularTableName
#	Global::log.info("in singularTableName self.class=#{self.class}")
#	Global::log.info("in singularTableName self.to_s=#{self.to_s}")
	return self.to_s.chop
end
def addColumn(name,type)
	sql="ALTER TABLE  #{@table_name} ADD COLUMN #{name.downcase} #{type};"
	errorMessage=DB.execute(sql)
	return errorMessage
end
def requireColumn(name,type)
#	Global::log.info("self.class=#{self.class}")
#	Global::log.info("name=#{name}")
	if has_attribute?(name) then
		return ""
	else
		puts "Column #{name} to be created with #{type}" if $VERBOSE
		return addColumn(name,type)
	end
end
def pg_table_exists?(tableName=self.to_s.downcase)
	sql="select table_name from information_schema.tables where table_schema='public' AND table_name='#{tableName}';"
#	Global::log.debug("sql=#{sql}")
	res  = find_by_sql(sql)
#	Global::log.info("res.size=#{res.size}")
	#puts "res=#{res}"
	return res.size>0
end
def addPrefix(variableHash,prefix)
	ret=Hash.new
	variableHash.each_pair do |key,value|
		ret["#{prefix}#{key}"]=value
	end
	return ret
end
def exclude(variableHash,exclusionList=[])
	ret=Hash.new
	variableHash.each_pair do |key,value|
		if !exclusionList.include?(key)
			ret[key]=value
		end
	end
end
def initFail
	puts "Table does not exist. Enter following command in rails to create:"
	puts self.class.scaffold
	exit
end
def Generic_Table.rubyClassName(model_class_name)
	model_class_name=model_class_name[0,1].upcase+model_class_name[1,model_class_name.length-1] # ruby class names are constants and must start with a capital letter.
	# remainng case is unchanged to allow camel casing to separate words for model names.
	return model_class_name
end #def
def Generic_Table.classDefiniton(model_class_name)
	return "class #{Generic_Table.rubyClassName(model_class_name)}  < ActiveRecord::Base\ninclude Generic_Table\nend"
end #def
def Generic_Table.classReference(model_class_name)
	rubyClassName=Generic_Table.rubyClassName(model_class_name)
	model_class_eval=eval("#{classDefiniton(rubyClassName)}\n#{rubyClassName}")
	return model_class_eval
end #def
def sequential_id?
	if self.respond_to?(:logical_primary_key) then
		if logical_primary_key==:created_at then # still sequential, not requred, default
			return true
		else
			return false
		end
	else # default to sequential id
		return true
	end #if
end # def
def logical_primary_key_value
	if sequential_id? then
		return self[:created_at]
	else
		return self[logical_primary_key]
	end #if
end #def
def table2yaml(table_name=self.class.name.tableize)
	i = 0 #"000"
	limit=100 # too long slow all tsts, too short give poor test coverage
	sql  = "SELECT * FROM %s LIMIT #{limit}"
    	File.open("test/fixtures/#{table_name}.yml.gen", 'w') do |file|
      		data = self.class.limit(limit).all
#		puts "data.inspect=#{data.inspect}"
		file.write "# Read about fixtures at http://ar.rubyonrails.org/classes/Fixtures.html"
		 file.write data.inject({}) { |hash, model_instance|
			i=i+1
			fixture_attributes=model_instance.attributes
			fixture_attributes.delete('created_at')  # automatically regenerated
			fixture_attributes.delete('updated_at')  # automatically regenerated
			if sequential_id? then
				primaryKeyValue=i
				fixture_attributes['id']=i  # automatically regenerated
			else
				primaryKeyValue=model_instance.logical_primary_key_value
				fixture_attributes.delete('id')  # automatically regenerated
			end
#			puts "fixture_attributes.inspect=#{fixture_attributes.inspect}"
#			puts "fixture_attributes.to_yaml.inspect=#{fixture_attributes.to_yaml.inspect}"
			hash[primaryKeyValue] = fixture_attributes
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
# Display attribute or method value from association even if association is nil
def associated_to_s(assName,method,*args)
	if self[assName.to_s+'_id'].nil? then # foreign key uninitialized
		return ''
	else
		ass=send(assName)
		if ass.nil? then
			return ''
		else
			return ass.send(method.to_sym,*args).to_s
		end
	end
end #def
end # module

