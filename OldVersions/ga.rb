###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'active_record'
require 'arConnection.rb'
require 'inlineAssertions.rb'
require 'model.rb'
class Generic_Acquisitions < ActiveRecord::Base
attr_reader :acquisitionData
attr_writer :acquisition_class,:modelRef
include Inline_Assertions
def initialize(model_class_name,test=false)
	Global::log.info("Generic_Acquisitions.initialize called with model_class_name =#{model_class_name}")
	assert_not_nil(model_class_name)
	if !test then
		@modelRef=MODEL_REFS[model_class_name]
		assert_not_nil(@modelRef)
		assert_not_nil(self)
		@acquisition_class= Acquisition_Classes.class_Reference(model_class, acquisition_interface, parse_interface)

		if @modelRef.table_exists? then
		else
			puts "Table does not exist. Enter following command in rails to create:"
 			columns=column_Definitions
# 		puts columns
# 		puts @modelRef.scaffold(column_Definitions)
		end #if
	end #if
end #def
def acquire
	return @acquisition_class.acquire
end
def parseVariableSets(acquisitionData)
	if table_selection.nil? || table_selection.empty? then
		 extractedTable=acquisitionData
	elsif table_selection_is_regexp then
		matchData=Regexp.new(table_selection).match(acquisitionData)
		extractedTable=matchData[0]
	else
	end #if
	if column_name_location=='header' then
		names=@acquisition_class.parseHeader(extractedTable,column_name_selection)
	end #if
	rows=@acquisition_class.parseTree(extractedTable,row_selection)
	rows.collect do |row|
		variableHash={}
		columns=@acquisition_class.parseTree(row,column_selection)
		columns.each_index do |icolumn|
			if column_name_location=='tagged' then
				name=@acquisition_class.parseTree(columns[icolumn].inner_html,huell.column_name_selection)
			else
				name=names[icolumn]
			end #if
			Global::log.debug("name.inspect=#{name.inspect}")
			value=@acquisition_class.parseTree(columns[icolumn],column_value_selection).inner_html
			Global::log.debug("value.inspect=#{value.inspect}")
			variableHash[name]=value
#			puts "variableHash.inspect=#{variableHash.inspect}"
		end #each
		Global::log.info("variableHash.inspect=#{variableHash.inspect}")
		variableHash
	end #collect
end #def
def parse
	ret = @acquisition_class.parse
	return ret
end
def parseVariableSet(row)
	variableHash={}
	columns=@acquisition_class.parseTree(row,column_selection)
	columns.each_index do |icolumn|
		if column_name_location=='tagged' then
			name=@acquisition_class.parseTree(columns[icolumn].inner_html,huell.column_name_selection)
		else
			name=names[icolumn]
		end #if
		Global::log.debug("name.inspect=#{name.inspect}")
		value=@acquisition_class.parseTree(columns[icolumn],column_value_selection).inner_html
		Global::log.debug("value.inspect=#{value.inspect}")
		variableHash[name]=value
#			puts "variableHash.inspect=#{variableHash.inspect}"
		end #each
	variableHash
end #def
def parse
	ret = @acquisition_class.parse
	return ret
end
def acquisitionUpdated?(acquisitionData)
	if firstAcquitition? then
		return true
	elsif dataInvalid? then
		return false
	else
		return true
	end
end
def acquisitionsUpdated?
	return @acquisitionData.inject(false){|reduction,e| reduction or acquisitionUpdated?(e)}
end
def firstAcquitition?
	if @acquisitionData.nil? then
		return true
	else
		return false
	end
end
def dataInvalid?
	if @acquisitionData.nil? then
		Global::log.info("@acquisitionData is nil")
		return true
	elsif @acquisitionData=="" then
		Global::log.info("empty line.")
		retrn true
	else
		Global::log.debug("in getValues else @acquisitionData=#{@acquisitionData}")
	        return false
	end #if
end #def

def Generic_Acquisitions.typeRecords(model_class_name)
	return Generic_Acquisitions.all(:conditions =>{:model_class=>model_class_name}) 
end #def
def Generic_Acquisitions.acquisition_class(typeRecord)
	assert_not_nil(typeRecord)
	ret =typeRecord.collect do  |tr|
		assert_instance_of(Generic_Acquisitions,tr)
		assert_not_nil(tr.model_class)
		assert_not_nil(tr.acquisition_interface)
		assert_not_nil(tr.parse_interface)
		Acquisition_Classes.new(tr.model_class,tr.acquisition_interface,tr.parse_interface)
	end
	return ret
end #def

def Generic_Acquisitions.urls(acquisition_class)
	Global::log.debug("acquisition_class.inspect=#{acquisition_class.inspect}")
	urlRecords = Generic_Acquisitions.all( :select => 'url',:conditions =>{:model_class=>acquisition_class.model_class,:acquisition_interface => acquisition_class.acquisition_interface,:parse_interface => acquisition_class.parse_interface}) 
	ret=urlRecords.collect {|u| u.url}
	Global::log.debug("Generic_Acquisitions.acquire.inspect=#{ret.inspect}")
	return ret
end
def Generic_Acquisitions.parseTypeRecords(acquisition_class)
	urls=urls(acquisition_class)
	ret={}
	urls.each do |url| 
		trs = Generic_Acquisitions.all(:conditions =>{:model_class=>acquisition_class.model_class,:acquisition_interface => acquisition_class.acquisition_interface,:parse_interface => acquisition_class.parse_interface, :url => url}) 
		ret[url]= trs
	end #each
	return ret
end #def

def Generic_Acquisitions.column_Definitions
	return [
	['Table_Name','string'],
	['Acquisition','string'],
	['URL','string'],
	['Table_Start','string'],
	['Table_End','string'],
	['Row_Start','string'],
	['Row_End','string']
	]
end #def
end #class
