require 'app/models/global.rb'
#require 'lib/tasks/testing_file_patterns.rb'
module ActiveRecord
class Base
def column_html(column_symbol)
	return self[column_symbol].inspect
end #column_html
def row_html(column_order=nil)
	ret="<tr>"
	column_order.each do |col|
		ret+='<td>'+column_html(col).inspect+'</td>'
	end #each
	ret+="</tr>"
	return ret

end #row_html
def Base.header_html(column_order=nil)
	if column_order.nil? then
		column_order=self.column_names
	end #if
	ret="<tr>"
	column_order.each do |header|
		ret+='<th>'+header+'</th>'
	end #each
	ret+="</tr>"
	return ret
end #header_html
def Base.table_html(column_order=nil)
	if column_order.nil? then
		column_order=self.column_names
	end #if
	ret="<table>"
	ret+=header_html(column_order)
	self.all.each do |row|
		ret+=row.row_html(column_order)
	end #each
	ret+="</table>"
	return ret
end #table_html
def Base.foreign_key_names
	content_column_names=content_columns.collect {|m| m.name}
#	puts "@content_column_names.inspect=#{@content_column_names.inspect}"
	special_columns=column_names-content_column_names
#	puts "@special_columns.inspect=#{@special_columns.inspect}"
	possible_foreign_keys=special_columns.select { |m| m =~ /_id$/ }
	return possible_foreign_keys
end #foreign_key_names
def Base.foreign_key_association_names
	foreign_key_names.map {|fk| fk.sub(/_id$/,'')}
end #foreign_key_association_names
def Base.associated_foreign_key_name(association_referenced_by_foreign_key)
	if !is_association?(association_referenced_by_foreign_key.to_s.singularize) then
		raise "Association #{association_referenced_by_foreign_key.to_s.singularize} is not an association of #{self.name}."
	end #if
	many_to_one_foreign_keys=foreign_key_names
	matchingAssNames=many_to_one_foreign_keys.select do |fk|
		ass=fk[0..-4].to_sym
		ass==association_referenced_by_foreign_key.to_s.singularize.to_sym
	end #end
	if matchingAssNames.size==0 then
		raise "Association #{association_referenced_by_foreign_key} does not have a corresponding foreign key in association #{self.name}."
	end #if
	return matchingAssNames.first
end #associated_foreign_key_name
# find 
def associated_foreign_key_records(association_with_foreign_key)
	class_with_foreign_key=self.class.association_class(association_with_foreign_key)
	foreign_key_symbol=class_with_foreign_key.associated_foreign_key_name(self.class.name.tableize)
	associated_records=class_with_foreign_key.where(foreign_key_symbol => self[:id])

	return associated_records
end #associated_foreign_key_records
def Base.is_matching_association?(association_name)
	 if is_association?(association_name) then
		association_class=association_class(association_name)
		 if association_class.nil? then
			 raise "Association #{association_name.classify} is not a defined constant."
		end #if
		table_symbol=association_class.association_method_symbol(self)
		 if association_class.is_association?(table_symbol) then
			 return true
		elsif association_class.is_association?(association_method_symbol(self.table_name.singularize.to_sym))  then
			return true
		else
			 return false
		end #if
	else
		return false
	end #if
end #is_matching_association
def Base.association_methods(association_name)
	return matching_instance_methods(association_name,false)
end #association_methods
def Base.association_patterns(association_name)
	patterns=association_methods(association_name).map do |n| 
		matchData=Regexp.new(association_name.to_s).match(n)
		Regexp.new('^'+matchData.pre_match+'([a-z0-9_]+)'+matchData.post_match+'$')
	end #map
	return Set.new(patterns)
end #association_patterns
def Base.match_association_patterns?(association_name,association_pattern)
	patterns=association_methods(association_name).map do |n| 
		matchData=association_pattern.match(association_pattern)
	end #map
	
	instance_respond_to?(association_name)
end #match_association_patterns
def Base.is_association_patterns?(association_name,association_patterns)
	(association_patterns(association_name)-association_patterns.to_a).empty?&&
	(association_patterns-association_patterns(association_name).to_a).empty?
end #is_association_patterns
def Base.is_association?(association_name)
	# Don’t create associations that have the same name as instance methods of ActiveRecord::Base.
	if ActiveRecord::Base.instance_methods_from_class.include?(association_name.to_s) then
		raise "# Don’t create associations that have the same name (#{association_name.to_s})as instance methods of ActiveRecord::Base (#{ActiveRecord.instance_methods_from_class})."
	end #if
	if association_name.to_s[-4,4]=='_ids' then # automatically generated
		return false
	elsif self.instance_respond_to?(association_name) and self.instance_respond_to?((association_name.to_s+'=').to_sym)  then
		return true
	else
		return false
	end
end #is_association
def Base.is_association_to_one?(assName)
	if is_association?(assName)  and !self.instance_respond_to?((assName.to_s.singularize+'_ids').to_sym) and !self.instance_respond_to?((assName.to_s.singularize+'_ids=').to_sym) then
		return true
	else
		return false
	end
end #association_to_one
def Base.is_association_to_many?(assName)
	if is_association?(assName)  and self.instance_respond_to?((assName.to_s.singularize+'_ids').to_sym) and self.instance_respond_to?((assName.to_s.singularize+'_ids=').to_sym) then
		return true
	else
		return false
	end
end #is_association_to_many
@@Example_polymorphic_patterns=Set.new([/^([a-z0-9_]+)$/, /^set_([a-z0-9_]+)_target$/, /^([a-z0-9_]+)=$/, /^autosave_associated_records_for_([a-z0-9_]+)$/, /^loaded_([a-z0-9_]+)?$/])

def Base.is_polymorphic_association?(association_name)
	return is_association_patterns?(association_name,@@Example_polymorphic_patterns)
end #is_polymorphic_association
def Base.association_names_to_one
	return instance_methods(false).select {|m| is_association_to_one?(m)}
end #def
def Base.association_names_to_many
	return instance_methods(false).select {|m| is_association_to_many?(m)}
end #def
def Base.association_names
	return instance_methods(false).select {|m| is_association_to_one?(m) or is_association_to_many?(m)}
end #def
def Base.model_file_name
	return "app/models/#{name.tableize.singularize}.rb"
end #def
def Base.model_grep(model_regexp_string)
	if !Generic_Table.rails_MVC_class?(self.name) then
		raise "#{self.name}.model_grep only works on Rails MVC."
	end #if
	return "grep \"#{model_regexp_string}\" #{model_file_name} &>/dev/null"
end #def
def Base.association_grep(model_regexp_string,association_name)
	return model_grep("^#{model_regexp_string} :#{association_name}" )
end #def
def Base.has_many_association?(association_name)
	return system(association_grep('has_many',association_name))
end #def
def Base.belongs_to_association?(association_name)
	return system(association_grep('belongs_to',association_name))
end #def
def Base.association_method_plurality(association_table_name)
	if self.instance_respond_to?(association_table_name) then
		return association_table_name.to_sym
	elsif self.instance_respond_to?(association_table_name.to_s.singularize) then
		return association_table_name.to_s.singularize.to_sym
	elsif self.instance_respond_to?(association_table_name.to_s.pluralize) then
		return association_table_name.to_s.pluralize.to_sym
	else # don't know what to do; most likely cure
		return association_table_name.to_s.pluralize.to_sym
	end #if
end #def
def Base.name_symbol(association_table_name)
	if association_table_name.kind_of?(Class) then
		return association_table_name.name.tableize.to_sym					
	elsif association_table_name.kind_of?(String) then
		return association_table_name.to_sym						
	elsif association_table_name.kind_of?(Symbol) then
		return association_table_name.to_sym
	else # other object
		return association_table_name.class.name.tableize.to_sym
	end #if
end #def
def Base.association_method_symbol(association_table_name)
	return association_method_plurality(name_symbol(association_table_name))
end #def
def Base.class_of_name(name)
	 return name.to_s.classify.constantize
end #def
def Base.association_class(assName)
	 if !is_association?(association_method_symbol(assName)) then
		raise "#{association_method_symbol(assName)} is not an association of #{self.name}."
	else
		 return class_of_name(assName)
	end #if
end #def

def Base.association_to_type(association_name)
	if is_association_to_one?(association_name) then
		return :to_one
	elsif is_association_to_many?(association_name) then
		return :to_many
	else 
		return :not_an_association
	end #if
end #association_to_type
def Base.association_macro_type(association_name)
	if  has_many_association?(association_name) then
		return :has_many
	elsif belongs_to_association?(association_name) then
		return :belongs_to
	else
		return :neither_has_many_nor_belongs_to
	end #if
end #def
def Base.association_type(association_name)
	return (association_to_type(association_name).to_s+'_'+association_macro_type(association_name).to_s).to_sym
end #def
def Base.is_active_record_method?(method_name)
	if ActiveRecord::Base.instance_methods_from_class(true).include?(method_name.to_s) then
		return true
	else
		return false
	end #if
end #is_active_record_method
#def Base.logical_primary_key
#	return column_names
#end #logical_primary_key
def Base.sequential_id?
	if self.respond_to?(:logical_primary_key) then
		if logical_primary_key==[:created_at] then # still sequential, not requred, default
			return true
		else
			return false
		end
	else # default to sequential id
		return true
	end #if
end # def
def logical_primary_key_value(delimiter=',')
	if self.class.sequential_id? then
		return self[:created_at]
	else
		return self.class.logical_primary_key.map {|k| self[k]}.join(delimiter)
	end #if
end #def


end #class Base
end #module ActiveRecord

module Generic_Table
require 'app/models/IncludeModuleClassMethods.rb'
 mixin_class_methods { |klass|
 puts "Module Acquisition has been included by #{klass}" if $VERBOSE
 }
define_class_methods {
} # define_class_methods
def Generic_Table.is_generic_table?(model_class_name)
	return false if (model_class_name =~ /_ids$/)
	if Generic_Table.is_ActiveRecord_table?(model_class_name) then
		model_class=Generic_Table.eval_constant(model_class_name.classify)
		model_class.module_included?(Generic_Table)
	else
		return false
	end #if
end #def
def Generic_Table.table_exists?(table_name)
	TableSpec.connection.table_exists?(table_name)
end #def
def Generic_Table.rails_MVC_class?(table_name)
	return Generic_Table.rails_MVC_classes.map {|c| c.name}.include?(table_name.to_s.classify)
end #def
def Generic_Table.is_generic_table_name?(model_file_basename,directory='app/models/',extention='.rb')
	if File.exists?(directory+model_file_basename+extention) then
		return true
	else
#		puts "File.exists?(\"#{directory+model_file_basename+extention})\")=#{File.exists?(directory+model_file_basename+extention)}"
		return false
	end #if
end #def
@@ALL_VIEW_DIRS||=Dir['app/views/*']
def Generic_Table.rails_MVC_classes
#	puts fixture_names.inspect
	@@ALL_VIEW_DIRS.map do |view_dir|
		model_filename=view_dir.sub(%r{^app/views/},'')
		if is_generic_table_name?(model_filename.singularize) then
			model_filename.classify.constantize
		else
#			puts "File.exists?(\"app/models/#{model_filename}\")=#{File.exists?('app/models/'+model_filename)}"
			nil # discarded by later Array#compact
		end #if
	end.compact #map
end #def
def Generic_Table.generic_table_class_names
	return model_classes.map { |klass| klass.name }
end #def


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
	acqClasses.each map do |ac|
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
	@acqClasses.map do |ac|
		@acquisitionData=acquire
	end #map
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
def table2yaml(table_name=self.class.name.tableize)
	i = 0 #"000"
	limit=100 # too long slow all tests, too short give poor test coverage
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
def association_state(assName)
	case self.class.association_to_type(assName)
	when :to_one
		foreign_key_value=self[assName.to_s+'_id']
		if foreign_key_value.nil? then # foreign key uninitialized
			return "Foreign key #{assName.to_s}_id defined as attribute but has nil value."
		#~ elsif foreign_key_value.empty? then # foreign key uninitialized
			#~ return "Foreign key #{assName.to_s}_id defined as attribute but has empty value."
		else
			ass=send(assName)
			if ass.nil? then
				return "Foreign key #{assName.to_s}_id has value #{foreign_key_value.inspect} but the association returns nil."
			else
				return "Foreign key #{assName.to_s}_id has value #{foreign_key_value.inspect},#{ass.inspect} and returns type #{ass.class.name}."
			end
		end
	when :to_many
		ass=send(assName)
		associations_foreign_key_name=(self.class.name.tableize.singularize+'_id').to_sym
		if ass.nil? then
			return "Association #{assName}'s foreign key #{associations_foreign_key_name} has value #{ass[self.class.name.to_s+'_id']} but the association returns nil."
		elsif ass.empty? then
			ret= "Association #{assName} with foreign key #{associations_foreign_key_name} is empty; "
			case self.class.association_class(assName).association_macro_type(self.class.name.tableize.singularize)
			when :has_many
				return ret+"but has many."
			when :belongs_to
				return ret+"but belongs_to."
			when :neither_has_many_nor_belongs_to
				return ret+"because neither_has_many_nor_belongs_to."
			else
				return "New return value from #{self.class.name}.association_macro_type(#{assName})=#{self.class.association_macro_type(assName)}."
			end #case
		else
			associations_foreign_key_values=ass.map { |a| a.send(associations_foreign_key_name) }.uniq.join(',')
			return "Association #{assName}'s foreign key #{associations_foreign_key_name} has value #{associations_foreign_key_values},#{ass.inspect} and returns type #{ass.class.name}."
		end
		
	when :not_generic_table
		return "#{self.class.name} does not recognize #{assName} as a generic table."
	when:not_an_association
		return "#{self.class.name} does not recognize #{assName} as association."
	else
		return "New return value from #{self.class.name}.association_to_type(#{assName})=#{self.class.association_to_type(assName)}."
	end #if
end #def
def association_has_data(assName)
	return association_state(assName)[/ and returns type /,0]
end #def
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
def Match_and_strip(regexp=/=$/)
	matching_methods(regexp).map do |m|
		m.sub(regexp,'')
	end
end #def
def Generic_Table.tables
	TableSpec.new.tables
end #def
def Generic_Table.eval_constant(constant_name)
	constant_name.constantize
rescue NameError
	return nil
end #def
def Generic_Table.is_table?(table_name)
	raise "table_name must include only [A-Za-z0-9_]." if (table_name =~ /^[A-Za-z0-9_]+$/).nil?
	if Generic_Table.table_exists?(table_name) then
		return true
	#~ elsif Generic_Table.table_exists?(table_name.tableize) then
		#~ return true
	else
		return false
	end #if
end #def
def Generic_Table.is_ActiveRecord_table?(model_class_name)
	if Generic_Table.is_table?(model_class_name.tableize) then
		model_class=Generic_Table.eval_constant(model_class_name.classify)
		model_class.new.kind_of?(ActiveRecord::Base)
	else
		return false
	end #if
end #def
def display_full_time(time)
	time.rfc2822
end #def
def Generic_Table.syntax_error(code)
	method_def= "def syntax_check_temp_method\n#{code}\nend\n"
	instance_eval(method_def)
	return nil
rescue  SyntaxError => exception_raised
	return exception_raised.to_s
end #def
def Generic_Table.short_error_message(code)
	error_message= Generic_Table.syntax_error(code)
	if error_message.nil? then
		return nil
	else
		return error_message.sub(%r{^\(eval\):\d+:in `syntax_error': compile error},'').gsub(%r{\(eval\):\d+: syntax error, },'').gsub(%r{\(eval\):\d+: },'')
	end #if
end #def
def Generic_Table.no_syntax_error?(code)
	method_def= "def syntax_check_temp_method\n#{code}\nend\n"
	instance_eval(method_def)
	return true
rescue  SyntaxError => exception_raised
	return false
end #def

end # module

