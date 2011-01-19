###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_gem "activerecord"
require 'active_record'
require 'arConnection.rb'
require 'global.rb'
require 'inlineAssertions.rb'
module Generic_Table
#include Structure_From_Data
def updates(variableHashes)
	Global::log.info("variableHashes.inspect=#{variableHashes.inspect}")
	variableHash={} # merge into single hash
	variableHashes.each do |vhs|
		vhs.each do |vh|
			variableHash.merge(vh)
		end #each
	end #each
	Global::log.info("variableHash.inspect=#{variableHash.inspect}")
	if exists?(variableHash) then
		@@log.debug("record already exists")
	else
		row=self.new
		Global::log.info( "variableHash['khhr_observation_time_rfc822']=#{variableHash['khhr_observation_time_rfc822']}")
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
	Global::log.info("in monitor self.name=#{self.name}")
	whoAmI
	#generic_acquisitions
	begin
		acquisitionData=acquire
		if self.acquisitionsUpdated?(acquisitionData) then
			row=find_or_initialize(keys)
			row.process(acquisitionData)
			row.printLog
		else
			Global::log.info(acquisitionData)
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
	Global::log.debug("names=#{names}")
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
		Global::log.info("#{names[i]} #{@sqlTypes[i]} \"#{@sqlValues[i]}\" #{typeNums[i]}")
		ret.push([names[i],@sqlTypes[i]])
		Global::log.info("ret=#{ret}")
	end
	Global::log.info("ret=#{ret}")
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
				Global::log.info("notModifieds=#{notModifieds}")
				Global::log.info("@acquisitionData=#{@acquisitionData}")
			else
				Global::log.info("not updated")	
			end
		end	
		#sleep self[:interval]
		wait
	end until done
	Global::log.info("notModifieds=#{notModifieds}")
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
	Global::log.info("in singularTableName self.class=#{self.class}")
	Global::log.info("in singularTableName self.to_s=#{self.to_s}")
	return self.to_s.chop
end # def
def Require_Table(tableName=self.to_s)
	Global::log.info("in Require_Table self.class=#{self.class}")
	Global::log.info("in Require_Table self.to_s=#{self.to_s}")
	Global::log.info("in Require_Table tableName=#{tableName}")
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
	Global::log.info("singularTableName=#{singularTableName}")
	Global::log.info("in scaffold singularTableName=#{singularTableName}")
	rails="script/generate scaffold #{singularTableName} "
	columnDefs.each do  |col|
		rails="#{rails} #{col[0]}:#{col[1]}"
		#puts rails
	end
	return rails
end
def singularTableName
	Global::log.info("in singularTableName self.class=#{self.class}")
	Global::log.info("in singularTableName self.to_s=#{self.to_s}")
	return self.to_s.chop
end
def addColumn(name,type)
	sql="ALTER TABLE  #{@table_name} ADD COLUMN #{name.downcase} #{type};"
	errorMessage=DB.execute(sql)
	return errorMessage
end
def requireColumn(name,type)
	Global::log.info("self.class=#{self.class}")
	Global::log.info("name=#{name}")
	if has_attribute?(name) then
		return ""
	else
		puts "Column #{name} to be created with #{type}" if $VERBOSE
		return addColumn(name,type)
	end
end
def pg_table_exists?(tableName=self.to_s.downcase)
	sql="select table_name from information_schema.tables where table_schema='public' AND table_name='#{tableName}';"
	Global::log.debug("sql=#{sql}")
	res  = find_by_sql(sql)
	Global::log.info("res.size=#{res.size}")
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
	rubyClassName=Generic_Acquisitions.rubyClassName(model_class_name)
	model_class_eval=eval("#{classDefiniton(rubyClassName)}\n#{rubyClassName}")
	return model_class_eval
end #def
end # module
MODEL_REFS={}
TABLES={}

class Table_spec < ActiveRecord::Base
has_many :acquisition_stream_specs, :class_name => "Acquisition_Stream_Spec"
#attr_reader 
include Inline_Assertions
@@schedule=Table_spec.all
@@scheduling_delay=1.0 # starting guess
@@log = Logger.new("model.log")
@@log.level = Logger::DEBUG
def blockUnderflow
	@@log.debug("beginning blockUnderflow"+sleepRange)
	self[:shortest_update]=[self[:shortest_update],@@scheduling_delay].compact.max
	self[:interval]=[self[:interval],@@scheduling_delay].compact.max
	self[:longest_no_update]=[self[:longest_no_update],@@scheduling_delay].compact.max
	@@log.debug("ending blockUnderflow"+sleepRange)
end #def
def after_initialize
	Global::log.debug("You have initialized an Table_spec object!")
	initializeState
	assert_model_counters
	assert(has_attribute?(:min_seconds))
	assert_not_nil(self[:min_seconds],"self="+self.inspect)
	assert_operator(self[:min_seconds],:>,0.0)
	if self[:interval].nil? || self[:interval]<= 0.0 then
		self[:interval]= (self[:min_seconds]+self[:max_seconds])/2.0
	end
	if self[:shortest_update].nil? || self[:shortest_update]<= 0.0  then
		update_attribute(:shortest_update, self[:min_seconds])
		assert_not_nil(self[:shortest_update])
		assert_equal(self[:min_seconds],self[:shortest_update])
	end
	assert_operator(self[:shortest_update],:>,0.0)
	if self[:longest_no_update].nil? || self[:longest_no_update]<= 0.0  then
		update_attribute(:longest_no_update, self[:max_seconds])
	end
	Global::log.debug("You have initialized an Table_spec object!")
	if self[:scheduled_time].nil? then
		update_attribute(:scheduled_time, Time.new)
	end
	assert_model_counters
	blockUnderflow
	@@log.debug(sleepRange)
	@acquisition_streams=acquisition_stream_specs.collect do |as|
		as # executes initialization code including class eval
	end
end #def
def parse
	@variableHash=@parse_classes.collect do |ac|
		ac.parse
	end
	return @variableHash.flatten
end
def urls
	@urls=acquisition_stream_specs.urls(@model_class_name)
	return @urls
end
def acquisitionsUpdated?
	acquisitionsUpdated=acquisition_stream_specs.any? do |ac|
		ac.acquisition_interface.acquisitionUpdated?
	end
	return acquisitionsUpdated
end #def
def flooredSleepInterval
	if self[:interval]> self[:max_seconds]
		Global::log.info("sleep self[:max_seconds]=#{self[:max_seconds]}")
		return self[:max_seconds]
	elsif self[:interval]<self[:min_seconds] then
		return self[:min_seconds]
	else
		Global::log.info("sleep self[:interval]=#{self[:interval]}")
		return self[:interval]
	end
end
def advanceScheduleTime(interval)
	assert_not_nil(interval)
	assert_equal(interval,flooredSleepInterval)
	Global::log.debug("interval=#{interval}")
	Global::log.info(" self[:scheduled_time]=#{ self[:scheduled_time]}")
	Global::log.info(" self[:scheduled_time]+interval=#{ self[:scheduled_time]+interval}")
	nextScheduledTime= self[:scheduled_time]+interval
	Global::log.info("nextScheduledTime=#{nextScheduledTime}")
	assert_operator(nextScheduledTime,:>, self[:scheduled_time],"schedule time didn't advance. interval=#{interval}when self=#{self}")
	self[:scheduled_time]=nextScheduledTime
	Global::log.info(" self[:scheduled_time]=#{ self[:scheduled_time]}")
#	assert_operator(self[:scheduled_time]-Time.now,:<,interval)
	nextScheduledTime
end #end
@@start_scheduling=Time.now # start guess
def self.nextAcquisition(lookAhead=false)
	@@schedule=@@schedule.sort{|a1,a2| a1.scheduled_time <=> a2.scheduled_time}
	scheduledModel=@@schedule.first # freeze decision while modifying
	@@scheduling_delay=Time.now-@@start_scheduling
	if !lookAhead then
		if scheduledModel.scheduled_time<=Time.now then
			scheduledModel.scheduled_time=Time.now # stretch schedule to reality
			Global::log.info("not sleeping at #{Time.now} for #{scheduledModel.inspect}")
		else
			assert_operator(scheduledModel.scheduled_time-Time.now,:<,scheduledModel.flooredSleepInterval)
			puts "At #{Time.now} sleeping #{scheduledModel.intervalString(scheduledModel.scheduled_time-Time.now)}"
			sleep scheduledModel.scheduled_time-Time.now	
		end
		scheduledModel.advanceScheduleTime(scheduledModel.flooredSleepInterval)
	end
	@@start_scheduling=Time.now
	@@log.debug("before blockUnderflow"+scheduledModel.sleepRange)
	scheduledModel.blockUnderflow # postgresql doesn't like float underflow
	@@log.debug("after blockUnderflow"+scheduledModel.sleepRange)
	scheduledModel.save
	return scheduledModel
end #end
#~ @@MODELS=Table_spec.all(:order => "id").collect { |m| m.model_class_name }
include Generic_Table
def acquire
	acs=acquisition_stream_specs
	acs.collect do |as| 
#		assert_kind_of(Acquisition,as.acquisition_interface)
		as.acquisition_interface.acquire
	end
end #def
 def initializeState
	@frozen=false
	@thawLength=0
	@freezeLength=0
	@previousThaw=0
	@previousFreeze=0
end
def assert_model_counters
	assert_not_nil(@frozen)
	assert_not_nil(@thawLength)
	assert_not_nil(@freezeLength)
	assert_not_nil(@previousThaw)
	assert_not_nil(@previousFreeze)
end #def
def intervalString(seconds)
	assert_operator(seconds,:>,0.0)
	assert_operator(seconds,:<,365*24*3600)
	days=(seconds/(24*3600))
	dayString=("%3i"%days)
	timeString=Time.at(seconds).getutc.strftime("%H:%M:%S")
	fractionalString="%4i"%((10000*seconds)%10000)
	dayString+'d '+timeString+"."+fractionalString
end #def
def sleepRange
	ret="#{intervalString(self[:min_seconds])}   "
	assert_operator(self[:shortest_update],:>,0.0)
	ret+= "#{intervalString(self[:shortest_update])} "
	ret+= "#{intervalString(self[:interval])}   "
	ret+= "#{intervalString(self[:longest_no_update])}  "
	ret+= "#{intervalString(self[:max_seconds])}  "
	ret+= "sd=#{@@scheduling_delay}"
	return ret
end #def
def checkFreeze(acquisitionsUpdated=acquisitionsUpdated?)
	if acquisitionsUpdated then
		if @frozen then #begin thaw
			@frozen=false
			@previousThaw=@thawLength	
			@thawLength=1
		else 
			@thawLength+=1
		end
	else
		if @frozen then
			@freezeLength+=1
		else
			@frozen=true
			@previousFreeze=@freezeLength
			@freezeLength=1
		end
	end
	return @freezeLength
	
end
def freezeMetric
	if @freezeLength > @previousFreeze then
		if @thawLength > @previousThaw
			return @freezeLength/(@freezeLength+@thawLength)
		else
			return @freezeLength/(@freezeLength+@previousThaw)
		end
	else
		if @thawLength > @previousThaw
			return @previousFreeze/(@previousFreeze+@thawLength)
		else
			return @previousFreeze/(@previousFreeze+@previousThaw)
		end
	end
end
def firstUpdateAfterInterruption?
	if @thawLength==1 then
		return true
	else
		return false
	end #if
end #def
@@TargetUpdates=0.9
@@a=@@TargetUpdates
@@b=(1.0-@@TargetUpdates)
def updateSleepInterval(acquisitionsUpdated=acquisitionsUpdated?)
	assert_model_counters
	checkFreeze(acquisitionsUpdated)
	assert_model_counters
	if acquisitionsUpdated then # might be too long; decrease interval, too_long, and too_short
		assert_not_nil(@thawLength)
		assert_operator(@thawLength,:>,0)
		if firstUpdateAfterInterruption? then
		end #if
		self[:longest_no_update]=self[:interval]/@thawLength
		assert_operator(self[:longest_no_update],:<,365*24*3600)
		self[:interval]=@@a*self[:shortest_update]+@@b*self[:longest_no_update]
		assert_operator(self[:interval],:>,0.0)
		assert_operator(self[:interval],:<,365*24*3600)
		assert_operator(self[:shortest_update],:>,0.0)
		assert_operator(self[:max_seconds],:>,0.0)
		self[:shortest_update]=[self[:interval],self[:shortest_update]].min
	else 
		self[:shortest_update]=0.5*self[:interval]+0.49*self[:shortest_update]
		self[:interval]=@@b*self[:shortest_update]+@@a*self[:longest_no_update]
		assert_operator(self[:interval],:<,365*24*3600)
		assert_not_nil(@freezeLength)
		self[:longest_no_update]=@@a*self[:longest_no_update]+@@b*self[:max_seconds]*@freezeLength
		assert_operator(self[:shortest_update],:>,0.0)
		@@log.debug(sleepRange)
	end
	assert_operator(self[:interval],:>,0.0)
	assert_operator(self[:interval],:<,365*24*3600)
	assert_operator(self[:shortest_update],:>,0.0)
	blockUnderflow # postgresql doesn't like float underflow
	return self[:interval] # result of most interest, other results are instance variables
end
def urls
	@urls=acquisition_stream_specs.collect {|acs| acs.url}
end
end #class
class Acquisition_Stream_Spec < ActiveRecord::Base 
belongs_to :table_spec, :class_name => "Table_spec"
validates_format_of :acquisition_interface, :with => /\A[a-zA-Z]{4,5}_Acquisition\z/,
    :message => "Only four or five letter mode followed by '_Acquisition' allowed."
include Inline_Assertions
def after_initialize
	Global::log.debug("You have initialized an Acquisition_Stream_Spec object!")
	assert_instance_of(String,self[:acquisition_interface])
	classReference= eval(self[:acquisition_interface])
	assert_not_nil(self[:url])
	objectReference=classReference.create(:url => self[:url])
	self[:acquisition_interface]=objectReference
end
def Acquisition_Stream_Spec.urls(model_class_name)
	return Acquisition_stream_specs.all(:order => "id",
:conditions =>{:model_class_name=>model_class_name}).collect { |m| m.url }
end #def
def acquire
	@acquisition_interface.acquire
end #def
end #class
