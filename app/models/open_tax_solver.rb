###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/generic_file.rb'
module OpenTableExplorer
module Constants
Data_source_directory='test/data_sources'
end #Constants
include Test::Unit::Assertions
extend Test::Unit::Assertions
def shell_command(command_string)
	puts command_string
	sysout=`#{command_string}`
	puts "sysout=#{sysout}"
	assert_equal('', sysout, "command_string=#{command_string} \nsysout=#{sysout}")
	sysout
end #shell_command
module Finance
module Constants
include OpenTableExplorer::Constants
Default_tax_year=2012
Open_Tax_Filler_Directory='../OpenTaxFormFiller'
Open_tax_solver_directory=Dir["../OpenTaxSolver2012_*"][0]
Open_tax_solver_data_directory="#{Open_tax_solver_directory}/examples_and_templates/US_1040"
Open_tax_solver_input="#{Open_tax_solver_data_directory}/US_1040_Lawson.txt"
Open_tax_solver_sysout="#{Open_tax_solver_data_directory}/US_1040_Lawson_sysout.txt"

Open_tax_solver_binary="#{Open_tax_solver_directory}/bin/taxsolve_US_1040_2012"
Command="#{Open_tax_solver_binary} #{Open_tax_solver_input} >#{Open_tax_solver_sysout}"
OTS_template_filename="#{Open_tax_solver_data_directory}/US_1040_template.txt"
end #Constants
class TaxForms
include Constants
include OpenTableExplorer
attr_reader :form, :jurisdiction, :tax_year, :form_filename, :open_tax_solver_directory, :open_tax_solver_data_directory, :ots_template_filename, :output_pdf
def initialize(form, jurisdiction='US', tax_year=Finance::Constants::Default_tax_year)
	@form=form
	@jurisdiction=jurisdiction # :US, or :CA
	@tax_year=tax_year
	@open_tax_solver_directory=Dir["../OpenTaxSolver#{@tax_year}_*"][0]
	@form_filename="#{@jurisdiction.to_s}_#{@form}"
	@open_tax_solver_data_directory="#{@open_tax_solver_directory}/examples_and_templates/#{@form_filename}"
	@open_tax_solver_output="#{open_tax_solver_data_directory}/#{@form_filename}_Lawson.txt"
	@ots_template_filename="#{Open_tax_solver_data_directory}/#{@jurisdiction.to_s}_#{@form}_template.txt"
	@output_pdf="#{Data_source_directory}/#{@form_filename}_otff.pdf"
	
end #initialize
def run_open_tax_solver
	open_tax_solver_input="#{open_tax_solver_data_directory}/US_1040_Lawson.txt"
	open_tax_solver_sysout="#{open_tax_solver_data_directory}/US_1040_Lawson_sysout.txt"
	command="#{Open_tax_solver_binary} #{open_tax_solver_input} >#{open_tax_solver_sysout}"
	shell_command(command)
end #run_open_tax_solver
def run_open_tax_solver_to_filler
	command="nodejs #{@open_Tax_Filler_Directory}/script/json_ots.js #{@open_tax_solver_sysout} > #{Data_source_directory}/US_1040_OTS.json"
	shell_command(command)
end #run_open_tax_solver_to_filler
module Assertions
def assert_post_conditions
	assert(File.exists?(@open_tax_solver_directory), caller_lines)
	assert(File.exists?(@open_tax_solver_data_directory), caller_lines)
	assert(File.exists?(@open_tax_solver_output), caller_lines)
	assert(File.exists?(@ots_template_filename), caller_lines)
end #assert_post_conditions
end #Assertions
include Assertions
end #TaxForms
end #Finance
end #OpenTableExplorer
class OpenTaxSolver
include GenericFiles
extend GenericFiles::ClassMethods
include GenericFiles::Assertions
extend GenericFiles::Assertions::ClassMethods
extend OpenTableExplorer::Finance::Constants
module Constants
include OpenTableExplorer::Finance::Constants
extend OpenTableExplorer::Finance::Constants
OTS_template_filename="#{Open_tax_solver_data_directory}/US_1040_template.txt"
Symbol_pattern='^ ?([-A-Za-z0-9?]+)'
Delimiter='\s+'
Specific_types=['\?\?', '0', ';', '0\s+;', 'Yes']
Type_pattern='(\s+|'+Specific_types.map{|a| '('+Delimiter+'('+a+')'+Delimiter+')'}.join('|')+')'
Description_pattern='\{(.+)\}'
Symbol_regexp=/#{Symbol_pattern}/
Type_regexp=/#{Symbol_pattern}#{Type_pattern}/
Description_regexp=/#{Description_pattern}/
Full_regexp=/#{Symbol_pattern}#{Type_pattern}#{Description_pattern}/
Full_regexp_array=[Symbol_pattern, Type_pattern, Description_pattern]
Open_Tax_Filler_Directory='../OpenTaxFormFiller'
Data_source_directory='test/data_sources'
end #Constants
include Constants
def self.input_file_names
	"#{Open_tax_solver_data_directory}/US_1040_template.txt"
end #input_file_names
def self.parse
	sequence_number=0
	raw_acquisitions.map do |acquisition|
	lines=acquisition.lines.map do |line|
		regexp=Regexp.new(Full_regexp_array.join)
		matchData=regexp.match(line)
		if matchData then
			name=matchData[1]
			type_chars=(matchData[4] || matchData[6] || matchData[8] || matchData[2]).strip # 
			description=matchData[-1].strip
		end #if
		tax_year=2012
		hash={:name => name, :type_chars => type_chars, :description => description, :tax_year => tax_year}
		sequence_number=sequence_number+1
		hash=hash.merge({:id => sequence_number})
	end.compact #each_line
	end.flatten #each_acquisition
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
def self.all
	All
end #all
def self.fine_rejections
	coarse_filter.select do |r| #map
		!Full_regexp.match(r)
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
		assert_match(Full_regexp, example_acquisition)
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
	matchData=Full_regexp.match(acquisition)
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
		assert_match(Full_regexp,acquisition)
		fail acquisition
	end #if
end #assert_match
end #ClassMethods
end #Assertions
module Constants
All=OpenTaxSolver.all_initialize
end #Constants
require_relative '../../test/assertions/default_assertions.rb'
include Assertions
include Examples
include Constants
extend Assertions::ClassMethods
end #OpenTaxSolver

