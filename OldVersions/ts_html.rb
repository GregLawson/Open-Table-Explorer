###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit'
#require 'generic.rb'
require 'global.rb'
require 'ga.rb'
require 'acquire.rb'
require 'parse.rb'
require 'regexp_Edit.rb'
class Huell_ac
	include HTTP_Acquisition
	include HTML_Parse
end
class Weather_ac
	include HTTP_Acquisition
	include XML_Parse
end
def parseTreeTest(acClass,dataToParse,selection)
	assert_instance_of(String,selection)
	explain_assert_respond_to(acClass,:parse)
	explain_assert_respond_to(acClass,:parseTree)
	explain_assert_respond_to(acClass,:extract_import_text)
	ret=acClass.parse(dataToParse,selection)
	assert_not_nil(ret)
#debug	explain_assert_respond_to(ret,:each)
#debug	assert_block("Parse of '#{dataToParse.inspect}' with selection '#{selection}' has returned '#{ret.inspect} of size #{ret.size}'."){ret.size>0}
	return ret
end

def gaTest(acClass,model_class_name)
	typeRecord=Generic_Acquisitions.typeRecords(model_class_name)
	assert_block("#{model_class_name} not found in Table_specs.model_classes=#{Table_specs.model_classes.inspect}"){typeRecord.size>0}
	typeRecord=typeRecord[0] # only one
	explain_assert_respond_to(acClass,:acquire)
#debug	explain_assert_respond_to(acClass,:acquisitionUpdated?)
	acquisitionData=acClass.acquire(typeRecord.url)
	if typeRecord.table_selection.nil? || typeRecord.table_selection.empty? then
		 extractedTable=acquisitionData
	elsif typeRecord.table_selection_is_regexp then
		matchData=Regexp.new(typeRecord.table_selection,Regexp::MULTILINE).match(acquisitionData)
		if matchData.nil? then

		else
			matchDisplay(typeRecord.table_selection,acquisitionData)
			extractedTable=matchData[1]
			assert(extractedTable.size>0)
		end

	else
		extractedTable=parse(acquisitionData,typeRecord.table_selection)
		assert(extractedTable.size>0)

	end #if
#	assert(extractedTable.size>0)
	if extractedTable.nil? then
		extractedTable=acquisitionData
	end
	assert_instance_of(String,acquisitionData)
	assert(acquisitionData.length>0)
	variableHash={}
	if typeRecord.column_name_location=='header' then
		nameRow=acClass.parseTree(extractedTable,typeRecord.column_name_selection)
#		puts "nameRow.size=#{nameRow.size}"
		names=nameRow.collect do |column|
			puts "column.inspect=#{column.inspect}" if $DEBUG
			puts "name column=#{column.inner_html}" if $VERBOSE
			column.inner_html
		end
	end
	explain_assert_respond_to(acClass,:parseHeader)
	testCall(acClass,:parseHeader,extractedTable,"tr")
	testCall(acClass,:parseHeader,extractedTable,"tr:nth-child(0)")
	testCall(acClass,:parseHeader,extractedTable,"tr:nth-child(0)>td")
	testCall(acClass,:parseHeader,extractedTable,typeRecord.column_name_selection)
	rows=parseTreeTest(acClass,extractedTable,typeRecord.row_selection)
	assert(rows.size>0)
	rows.each do |row|
		puts "row.inspect=#{row.inspect}" if $DEBUG
		puts  "row.inner_html.inspect=#{row.inner_html.inspect}" if $DEBUG
		puts "typeRecord.column_selection.inspect=#{typeRecord.column_selection.inspect}" if $DEBUG
		columns=parseTreeTest(acClass,row,typeRecord.column_selection)
		puts "columns.inspect=#{columns.inspect}" if $DEBUG
		columns.each do |column|
			puts "column.inspect=#{column.inspect}" if $DEBUG
			puts "column.inner_html.inspect=#{column.inner_html.inspect}" if $DEBUG
			if typeRecord.column_name_location=='tagged' then
				name=parseTreeTest(acClass,column.inner_html,typeRecord.column_name_selection)
				puts "name.inspect=#{name.inspect}" if $DEBUG
			end
			value=parseTreeTest(acClass,column,typeRecord.column_value_selection).inner_html
			puts "value.inspect=#{value.inspect}" if $DEBUG
			variableHash[name]=value
		end
#		puts "value.inspect=#{value.inspect}"
		end #collect
	explain_assert_respond_to(typeRecord,:parseVariableSets)
	typeRecord.acquisition_class=acClass
	variableHashes=typeRecord.parseVariableSets(acquisitionData)
	assert(variableHashes.size>0)
	keys=[]
	variableHashes.each do |rowHash|
		keys=keys.concat(rowHash.keys).uniq
	end
	assert_equal(keys.sort,names.sort)
	puts "variableHashes.inspect=#{variableHashes.inspect}" if $DEBUG

end #def

class Test_Generic <Test::Unit::TestCase
require 'test_helpers.rb'

def test_models

	gaTest(Huell_ac,'huell_schedule')
	gaTest(Weather_ac,'MULTIPLE_WEATHER')
end #def
def test_editor
# 	regexpTest('K','K')
	typeRecord=Generic_Acquisitions.typeRecords('huell_schedule')[0]
	puts "typeRecord.inspect=#{typeRecord.inspect}" if $DEBUG
	dataToParse=Huell_ac.acquire(typeRecord.url)
#	regexpTest(typeRecord.table_selection,dataToParse)
end #def
end #class