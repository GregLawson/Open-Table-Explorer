###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'app/models/global.rb'
#require 'test/assertions/generic_table_assertions.rb' # in test_helper?
# Methods in common bettween ActiveRecord::Base and NoDB
module Generic_Table
module ClassMethods
include GenericTableHtml::ClassMethods
include GenericGrep::ClassMethods
include ColumnGroup::ClassMethods
def nesting
	return Module.nesting
end #nesting
def sample_burst(sample_type, start, spacing, consecutive)
	if consecutive>spacing then
		raise "consecutive(#{consecutive})>spacing(#{spacing})"
	end #if
	case sample_type
	when :first, :random
		return all[start, consecutive]
	when :last
		return all[start+spacing-consecutive, consecutive]
	else
		raise "Unknown sample type=#{sample_type}. Expected values are :first, :Last."
	end #case
end #sample_burst
# return a statified or random sample
# returns a nested array of sample records
# Usually you will want sample.flatten
# The nested structure is available for plotting (say different colors) to see locality and trends.
def sample(samples_wanted=100, sample_type=:first, consecutive=1)
	size=all.size
	samples_returned=[samples_wanted, size].min
	bursts=(samples_returned/consecutive).ceil
	spacing=(size/bursts).ceil
	ret=(0..bursts-1).map do |burst|
		burst_start=burst*spacing
		case sample_type
		when :first, :last
			sample_burst(sample_type, burst_start, spacing, consecutive)
		when :random
			burst_start=rand(samples_returned)
			sample_burst(sample_type, burst_start, spacing, consecutive)
		else
			raise "Unknown sample type=#{sample_type}. Expected values are :first, :random, :last"
		end #case
	end #map burst
	return ret #[0..samples_returned-1]
end #sample
def model_file_name
	return "app/models/#{name.tableize.singularize}.rb"
end #model_file_name
# Whether primay logical key has been overridden 
# or ActiveRecord::Base.logical_primary_key is used.
# nil returned if overridden.
# true returned otherwise.
# from http://en.wikipedia.org/wiki/Algorithms_for_calculating_variance
# Skewness is defined at http://en.wikipedia.org/wiki/Skewness
# kurtosis is defined at http://en.wikipedia.org/wiki/Kurtosis
def one_pass_statistics(column_name)
    n = 0
    mean = 0
    m2 = 0
    m3 = 0
    m4 = 0
    min=nil; max=nil
	max_key, min_key = nil # declare scope outside loop!
    has_id=column_names.include?('id')
    all.each do |row|
        x=row[column_name]
        n1 = n
        n = n + 1
        delta = x - mean
        delta_n = delta / n
        delta_n2 = delta_n * delta_n
        term1 = delta * delta_n * n1
        mean = mean + delta_n
        if n==1 then
	    min=x # value for nil
	    max=x # value for nil
	    if has_id then
		    min_key=row.id
		    max_key=row.id
	    else
		    min_key=row.logical_primary_key_value_recursive
		    max_key=row.logical_primary_key_value_recursive
	    end #if
	else
            m4 = m4 + term1 * delta_n2 * (n*n - 3*n + 3) + 6 * delta_n2 * m2 - 4 * delta_n * m3
            m3 = m3 + term1 * delta_n * (n - 2) - 3 * delta_n * m2
            m2 = m2 + delta*(x - mean)
	    if x<min then
	    	min=x
		if has_id then
		    min_key=row.id
	    	else
		    min_key=row.logical_primary_key_value_recursive
	    	end #if
	    end #if  # value for not nil
	    if x>max then
	    	max=x
		if has_id then
			max_key=row.id
		else
			max_key=row.logical_primary_key_value_recursive
		end #if
	    end #if  # value for not nil
	end #if
    end #each
    return nil if n==0
    {
    :n => n,
    :variance_n => m2/n,
    :variance => m2/(n - 1), 
    :skewness=> Math::sqrt(n)*m3/(m2**(3/2)),
    :kurtosis => (n*m4) / (m2*m2) - 3,
    :min => min,
    :min_key => min_key,
    :mean => mean,
    :max => max,
    :max_key => max_key,
    :has_id => has_id
    }
end #one_pass_statistics
# To detect collisions between attributes as methods and ActiveRecord methods.
def is_active_record_method?(method_name)
	if ActiveRecord::Base.instance_methods_from_class(true).include?(method_name.to_s) then
		return true
	else
		return false
	end #if
end #is_active_record_method
end #ClassMethods
include GenericTableHtml
include GenericGrep
include ColumnGroup
end #Generic_Table
module ActiveRecord

class Base
include Generic_Table
extend Generic_Table::ClassMethods
include GenericTableAssociation
extend GenericTableAssociation::ClassMethods
include ActionView::Helpers::UrlHelper


end #class Base
end #module ActiveRecord
module Common
require 'app/models/IncludeModuleClassMethods.rb'
def Generic_Table.class_of_name(name)
	 return name.to_s.constantize
rescue
	return nil
end #class_of_name
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
end #table_exists
def Generic_Table.rails_MVC_class?(table_name)
	return CodeBase.rails_MVC_classes.map{|c| c.name}.include?(table_name.to_s.classify)
end #rails_MVC_class
def Generic_Table.is_generic_table_name?(model_file_basename,directory='app/models/',extention='.rb')
	if File.exists?(directory+model_file_basename+extention) then
		return true
	else
#		puts "File.exists?(\"#{directory+model_file_basename+extention})\")=#{File.exists?(directory+model_file_basename+extention)}"
		return false
	end #if
end #is_generic_table_name


def Generic_Table.activeRecordTableNotCreatedYet?(obj)
	return (obj.class.inspect=~/^[a-zA-Z0-9_]+\(Table doesn\'t exist\)/)==0
end #activeRecordTableNotCreatedYet
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
	acquire
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
def acquire
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
def association_state(association_name)
	case self.class.association_arity(association_name)
	when :to_one
		foreign_key_value=foreign_key_value(association_name)
		if foreign_key_value.nil? then # foreign key uninitialized
			return "Foreign key #{association_name.to_s}_id defined as attribute but has nil value."
		#~ elsif foreign_key_value.empty? then # foreign key uninitialized
			#~ return "Foreign key #{association_name.to_s}_id defined as attribute but has empty value."
		else
			ass=send(association_name)
			if ass.nil? then
				return "Foreign key #{association_name.to_s}_id has value #{foreign_key_value.inspect} but the association returns nil."
			else
				return "Foreign key #{association_name.to_s}_id has value #{foreign_key_value.inspect},#{ass.inspect} and returns type #{ass.class.name}."
			end
		end
	when :to_many
		ass=send(association_name)
		associations_foreign_key_name=(self.class.name.tableize.singularize+'_id').to_sym
		if ass.nil? then
			return "Association #{association_name}'s foreign key #{associations_foreign_key_name} has value #{ass[self.class.name.to_s+'_id']} but the association returns nil."
		elsif ass.empty? then
			ret= "Association #{association_name} with foreign key #{associations_foreign_key_name} is empty; "
			case self.class.association_class(association_name).association_macro_type(self.class.name.tableize.singularize)
			when :has_many
				return ret+"but has many."
			when :belongs_to
				return ret+"but belongs_to."
			when :neither_has_many_nor_belongs_to
				return ret+"because neither_has_many_nor_belongs_to."
			else
				return "New return value from #{self.class.name}.association_macro_type(#{association_name})=#{self.class.association_macro_type(association_name)}."
			end #case
		else
			associations_foreign_key_values=ass.map { |a| a.send(associations_foreign_key_name) }.uniq.join(',')
			return "Association #{association_name}'s foreign key #{associations_foreign_key_name} has value #{associations_foreign_key_values},#{ass.inspect} and returns type #{ass.class.name}."
		end
		
	when :not_generic_table
		return "#{self.class.name} does not recognize #{association_name} as a generic table."
	when:not_an_association
		return "#{self.class.name} does not recognize #{association_name} as association."
	else
		return "New return value from #{self.class.name}.association_arity(#{association_name})=#{self.class.association_arity(association_name)}."
	end #if
end #def
def Match_and_strip(regexp=/=$/)
	matching_methods(regexp).map do |m|
		m.sub(regexp,'')
	end
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

end # module
module NoDB # provide duck-typed ActiveRecord like functions.
attr_reader :attributes
include ActiveModel # trying to fufil Rails 3 promise that ActiveModel would allow non-AActiveRecord classes to share methods.
include Generic_Table
extend Generic_Table::ClassMethods
module ClassMethods
include Generic_Table::ClassMethods
def column_symbols
	column_names=sample.flatten.map do |r|
		r.keys.map {|name| name.downcase.to_sym}
	end.flatten.uniq #map
end #column_symbols
end #ClassMethods
def initialize(hash=nil)


	if hash.nil? then
		@attributes=ActiveSupport::HashWithIndifferentAccess.new
	else
		@attributes=ActiveSupport::HashWithIndifferentAccess.new(hash)
	end #if
end #NoDB
def [](attribute_name)
	@attributes[attribute_name]
end #[]
def []=(attribute_name, value)
	@attributes[attribute_name]=value
end #[]
def has_key?(key_name)
	return @attributes.has_key?(key_name)
end #has_key?
def keys
	return @attributes.keys
end #keys
end #NoDB

