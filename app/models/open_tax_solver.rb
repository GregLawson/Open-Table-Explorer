###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/generic_files.rb'
class OpenTaxSolver
include GenericFiles
extend GenericFiles::ClassMethods
include GenericFiles::Assertions
extend GenericFiles::Assertions::ClassMethods
module Constants
Default_tax_year=2012
Open_tax_solver_directory="../OpenTaxSolver2012_10.00"
Open_tax_solver_data_directory="#{Open_tax_solver_directory}/examples_and_templates/US_1040"
Open_tax_solver_input="#{Open_tax_solver_data_directory}/US_1040_Lawson.txt"
Open_tax_solver_sysout="#{Open_tax_solver_data_directory}/US_1040_Lawson_sysout.txt"

Open_tax_solver_binary="#{Open_tax_solver_directory}/bin/taxsolve_US_1040_2012"
Command="#{Open_tax_solver_binary} #{Open_tax_solver_input} >#{Open_tax_solver_sysout}"
OTS_template_filename="#{Open_tax_solver_data_directory}/US_1040_template.txt"
Symbol_pattern='^ ?(?<name>[-A-Za-z0-9?]+)'
Delimiter='\s+'
Specific_types=['\?\?', '0', ';', '0\s+;', 'Yes']
Type_pattern='(?<blank_or_outter>\s+|'+Specific_types.map{|a| '(?<outter>'+Delimiter+'(?<type_chars>'+a+')'+Delimiter+')'}.join('|')+')'
Description_pattern='\{(?<description>.+)\}'
Symbol_regexp=/#{Symbol_pattern}/
Type_regexp=/#{Symbol_pattern}#{Type_pattern}/
Description_regexp=/#{Description_pattern}/
Full_regexp_array=[Symbol_pattern, Type_pattern, Description_pattern]
end #Constants
def self.input_file_names
	"#{Open_tax_solver_data_directory}/US_1040_template.txt"
end #input_file_names
def self.parse
	array_of_hashes=[]
	sequence_number=0
	raw_acquisitions.map do |acquisition|
		puts "start loop sequence_number=#{sequence_number}"
		begin
		hash={}
		regexp=Regexp.new(Full_regexp_array.join)
		matchData=regexp.match(acquisition)
		if matchData then
			matchData.names.map do |n|
				hash[n.to_sym]=matchData[n]
				puts "before sequence_number=#{sequence_number}"
				sequence_number=sequence_number+1
				puts "after sequence_number=#{sequence_number}"
				puts "end loop sequence_number=#{sequence_number}"
			end #map
			acquisition=matchData.post_match
		else
			acquisition=nil
		end #if
		array_of_hashes.push(hash)
		
		end until (acquisition.nil?) | (acquisition.empty?) | (acquisition.size==0)
		array_of_hashes
	end.flatten #map
end #parse
def self.input_file_names
	"#{Open_tax_solver_data_directory}/US_1040_template.txt"
end #input_file_names
def self.coarse_filter
	raw_acquisitions.map do |acquisition|
		matches=acquisition.lines.map do |line|
			if Type_regexp.match(line) && Description_regexp.match(line) then
				line
			else
				nil
			end #if
		end #each_line
	end.flatten.compact #select
end #coarse_filter
def self.coarse_rejections
	raw_acquisitions.map do |acquisition|
		matches=acquisition.lines.map do |line|
			if Type_regexp.match(line) && Description_regexp.match(line) then
				nil
			else
				line
			end #if
		end #each_line
	end.flatten.compact #select
end #coarse_rejections
def self.all(tax_year=Default_tax_year)
	coarse_filter.map do |r| #map
		matchData=Full_regexp_array.join.match(r)
		if matchData then
			ios=parse(r, Full_regexp_array.join)
			ios.map do |hash|
				OpenTaxSolver.new(hash, [String, String, String])
			end #map
		else
			nil
		end #if
	end.compact.flatten #map
end #all
def self.fine_rejections
	coarse_filter.select do |r| #map
		!Full_regexp_array.join.match(r)
	end #select
end #fine_rejections
module Examples
Simple_acquisition='L 0 {e}'
Short_acquisition='L  {e}'

end #Examples
require_relative '../../test/assertions/default_assertions.rb'

module Assertions
include Test::Unit::Assertions
extend Test::Unit::Assertions
def assert_pre_conditions
		assert_instance_of(OpenTaxSolver, self)
		assert_instance_of(Hash, self.attributes)
		assert_respond_to(self.attributes, :values)
		assert_scope_path(:DefaultAssertions, :ClassMethods)
		assert_constant_instance_respond_to(:NoDB, :insert_sql)
		assert_include(self.class.included_modules, NoDB)
#		assert_include(NoDB.methods, :insert_sql)
		assert_includes(self.methods, :insert_sql)
		explain_assert_respond_to(self, :insert_sql)
		assert_respond_to(self, :insert_sql)
		assert_instance_of(Array, attributes.values)
end #assert_pre_conditions
module ClassMethods
include OpenTaxSolver::Constants
include OpenTaxSolver::Examples
include Test::Unit::Assertions
extend Test::Unit::Assertions
include DefaultAssertions::ClassMethods
def assert_pre_conditions
	assert_scope_path(:DefaultAssertions, :ClassMethods)
	assert_include(included_modules, NoDB, "")
	Dir[input_file_names].each do |f|
		assert(File.exists?(f), Dir["#{Open_tax_solver_data_directory}/*"].inspect)
	end #each
end #assert_pre_conditions
def assert_post_conditions
#	assert_constant_instance_respond_to(:DefaultAssertions, :ClassMethods, :value_of_example?) #, "In assert_post_conditions calling assert_constant_instance_respond_to"
	Examples.constants.each do |name|
		example_acquisition=OpenTaxSolver.value_of_example?(name)
		assert_match(/#{Symbol_pattern}/, example_acquisition)
		assert_match(/#{Delimiter}/, example_acquisition)
		assert_match(/#{Type_pattern}/, example_acquisition)
		assert_match(/#{Description_pattern}/, example_acquisition)
		assert_match(Symbol_regexp, example_acquisition)
		assert_match(Type_regexp, example_acquisition)
		assert_match(Description_regexp, example_acquisition)
		assert_match(Full_regexp_array.join, example_acquisition)
	end #each
#hit	fail "end of CLASS assert_post_conditions"
end #assert_post_conditions
def assert_full_match(acquisition)
	message=caller_lines
	assert_match(/#{Symbol_pattern}/, acquisition, caller_lines)
	assert_match(/#{Delimiter}/, acquisition, caller_lines)
	assert_match(/#{Type_pattern}/, acquisition, caller_lines)
	assert_match(/#{Description_pattern}/, acquisition, caller_lines)
	assert_match(Symbol_regexp, acquisition, caller_lines)
	assert_match(Type_regexp, acquisition, caller_lines)
	assert_match(Description_regexp, acquisition, caller_lines)
	assert_not_empty(acquisition, caller_lines)
	assert_not_empty(caller_lines, caller_lines)
	assert_not_empty(Full_regexp_array, caller_lines)
	assert_not_empty(Full_regexp_array.join, caller_lines)
	assert_not_nil(Regexp.new(Full_regexp_array.join), caller_lines)
	assert_instance_of(Regexp, Regexp.new(Full_regexp_array.join), caller_lines)
	matchData=Regexp.new(Full_regexp_array.join).match(acquisition, caller_lines)
	matchData=Full_regexp_array.join.match(acquisition, caller_lines)
	if matchData then
		assert_equal(14, matchData.size, matchData.inspect)
		indices0=[2,4,6,8,10,12]
		matchMap0=[matchData[2].nil?, matchData[4].nil?, matchData[6].nil?, matchData[8].nil?, matchData[10].nil?, matchData[12].nil?]
		capture_nesting=[1,1,2,2,2,2,2,1]
		alternatives=[1,2,3,3,3,3,3,1]
		capture_kind=[:name, :''] + Specific_types + [:description]
		assert_equal(capture_nesting.size, capture_kind.size, caller_lines)
		assert_equal(alternatives.size, capture_kind.size, caller_lines)
		nesting=[]
		message0="#{caller_lines}matchData=#{matchData.inspect}#{}"
		Array.new(capture_kind.size) do |i|
			match_index=capture_nesting[0..i].reduce(:+)
			message=message0+"i=#{i}, match_index=#{match_index}, nesting=#{nesting.inspect}\ncapture_kind[i]=#{capture_kind[i]}"
			if capture_kind[i].instance_of?(String) then
				case alternatives[i] <=> nesting.size
				when +1	then nesting.push(match_index)
				when 0 then #puts "no push or pop nesting=#{nesting.inspect}"
				when -1 then nesting.pop
				else
					fail nesting.inspect
				end #case
				if !matchData[match_index].nil? then
					assert_equal(matchData[2], matchData[match_index-1], message)
					assert_match(/#{capture_kind[i]}/,matchData[match_index], message)
				end #if
			else # data
				assert_not_nil(matchData[match_index], message)
			end #if
		end #Array.new
		indices=Array.new((matchData.size-2)/2){|i| 2*(i+1)}
		assert_equal(indices0, indices)
		matchMap=indices.map{|i| matchData[i].nil?}
		assert_equal(matchMap0, matchMap,message)
		return
		case matchMap
		when [false, false, true, true, true] then 
			assert_equal('??', matchData[4], matchData.inspect)
			assert_equal(matchData[2], matchData[3], matchData.inspect)
		when [false, true, false, true, true] then 
			assert_equal('0', matchData[6], matchData.inspect)
			assert_equal(matchData[2], matchData[5], matchData.inspect)
		when [false, true, true, false, true] then 
			assert_equal(';', matchData[8], matchData.inspect)
			assert_equal(matchData[2], matchData[7] , matchData.inspect)
		when [false, true, true, true, false] then 
			assert_equal('0 ;', matchData[10], matchData.inspect)
			assert_equal(matchData[2], matchData[9] , matchData.inspect)
		when [false, true, true, true, false] then 
			assert_equal('Yes', matchData[12], matchData.inspect)
			assert_equal(matchData[2], matchData[11] , matchData.inspect)
		when [false, true, true, true, true] then 
			assert_match(/\s+/, matchData[2], matchData.inspect)
			assert_equal(matchData[2], matchData[3] || matchData[5] || matchData[7] , matchData.inspect)
		else
			fail matchMap.inspect+matchData.inspect
		end #case
	else
		assert_match(Full_regexp_array.join,acquisition)
		fail acquisition
	end #if
end #assert_match
end #ClassMethods
end #Assertions
require_relative '../../test/assertions/default_assertions.rb'
include Assertions
include Examples
include Constants
extend Assertions::ClassMethods
end #OpenTaxSolver

