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
class Weather_ac
	include HTTP_Acquisition
	include HTML_Parse
end
class Test_Generic <Test::Unit::TestCase
require 'test_helpers.rb'
def test_models
	weather=Generic_Acquisitions.typeRecords('MULTIPLE_WEATHER')
	assert(weather.size>0)
	weather=weather[0] # only one
	explain_assert_respond_to(Weather_ac,:acquire)
#debug	explain_assert_respond_to(Weather_ac,:acquisitionUpdated?)
	acquisitionData=Weather_ac.acquire(weather.url)
	if weather.table_selection.nil? || weather.table_selection.empty? then
		 extractedTable=acquisitionData
	elsif weather.table_selection_is_regexp then
		matchData=Regexp.new(weather.table_selection).match(acquisitionData)
		extractedTable=matchData[0]
	else
	end #if
	assert(extractedTable.size>0)
	assert_instance_of(String,acquisitionData)
	assert(acquisitionData.length>0)
	explain_assert_respond_to(Weather_ac,:parseTree)
	variableHash={}
	if weather.column_name_location=='header' then
		nameRow=Weather_ac.parseTree(extractedTable,weather.column_name_selection)
#		puts "nameRow.size=#{nameRow.size}"
		names=nameRow.collect do |column|
			puts "column.inspect=#{column.inspect}" if $DEBUG
			puts "name column=#{column.inner_html}" if $VERBOSE
			column.inner_html
		end
	end
	explain_assert_respond_to(Weather_ac,:parseHeader)
	assert(Weather_ac.parseHeader(extractedTable,weather.column_name_selection).size>0)
	rows=Weather_ac.parseTree(extractedTable,weather.row_selection)
	assert(rows.size>0)
	rows.each do |row|
		puts "row.inspect=#{row.inspect}" if $DEBUG
		puts  "row.inner_html.inspect=#{row.inner_html.inspect}" if $DEBUG
		puts "weather.column_selection.inspect=#{weather.column_selection.inspect}" if $DEBUG
		columns=Weather_ac.parseTree(row,weather.column_selection)
		puts "columns.inspect=#{columns.inspect}" if $DEBUG
		columns.each do |column|
			puts "column.inspect=#{column.inspect}" if $DEBUG
			puts "column.inner_html.inspect=#{column.inner_html.inspect}" if $DEBUG
			if weather.column_name_location=='tagged' then
				name=Weather_ac.parseTree(column.inner_html,weather.column_name_selection)
				puts "name.inspect=#{name.inspect}" if $DEBUG
			end
			value=Weather_ac.parseTree(column,weather.column_value_selection).inner_html
			puts "value.inspect=#{value.inspect}" if $DEBUG
			variableHash[name]=value
		end
#		puts "value.inspect=#{value.inspect}"
		end #collect
	explain_assert_respond_to(weather,:parseVariableSets)
	weather.acquisition_class=Weather_ac
	variableHashes=weather.parseVariableSets(acquisitionData)
	assert(variableHashes.size>0)
	keys=[]
	variableHashes.each do |rowHash|
		keys=keys.concat(rowHash.keys).uniq
	end
	assert_equal(keys.sort,names.sort)
	puts "variableHashes.inspect=#{variableHashes.inspect}"

end #def
end #class