###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/generic_files.rb'
module OpenTaxFormFiller
module Constants
Default_tax_year=2012
end #Constants

class Definitions
include NoDB
extend NoDB::ClassMethods
include GenericJsons
extend GenericJsons::ClassMethods
include GenericJsons::Assertions
extend GenericJsons::Assertions::ClassMethods
module Constants
include OpenTaxFormFiller::Constants
Open_tax_filler_directory="../OpenTaxFormFiller/#{Default_tax_year}"
Input_filenames="#{Open_tax_filler_directory}/definition/Federal/f*.json"
Data_source_directory='test/data_sources'
OTF_SQL_dump_filename="#{Data_source_directory}/OTF_SQL_dump_#{Default_tax_year}.sql"
end #Constants
include Constants
def self.input_file_names
	Input_filenames
end #input_file_names
def table_name?
	'Definitions'
end #model_name?
# returns array of hashes
def self.parse(acquisition) #acquisition=next
	json=JSON[acquisition]
	entries=[]
	json['fields'].each_pair do |key, value|
		flat={}
		flat[:form]=json['form']
		flat[:year]=json['year']
		flat[:line]=key
		flat[:type]=value
		entries.push(flat)
	end #each_pair
	entries
end #parse
def self.all
	All
end #all
module Examples
Simple_acquisition="{\"year\":2012,\"form\":\"f1040\",\"fields\":[{}]}"
All=Definitions.all_initialize


end #Examples
require_relative '../../test/assertions/default_assertions.rb'

module Assertions
include Test::Unit::Assertions
extend Test::Unit::Assertions
def assert_invariant
	assert_instance_of(Definitions, self)
#	assert_scope_path(:DefaultAssertions, :ClassMethods)
	assert_includes(self.methods, :insert_sql)
	explain_assert_respond_to(self, :insert_sql)
	assert_respond_to(self, :insert_sql)
	assert_equal([:form, :year, :line, :type], self.keys, self.inspect)
	assert_include(["Amount", "Choice", "Text", "Number", "Integer", "Percent"], self[:type])
end #assert_invariant
module ClassMethods
include Constants
include Examples
include Test::Unit::Assertions
extend Test::Unit::Assertions
include DefaultAssertions::ClassMethods
def assert_pre_conditions
#	assert_scope_path(:DefaultAssertions, :ClassMethods)
	assert_include(included_modules, NoDB, "")
end #assert_pre_conditions
def assert_post_conditions
#	assert_constant_instance_respond_to(:DefaultAssertions, :ClassMethods, :value_of_example?) #, "In assert_post_conditions calling assert_constant_instance_respond_to"
	Examples.constants.each do |name|
		example_acquisition=Definitions.value_of_example?(name)
	end #each
#hit	fail "end of CLASS assert_post_conditions"
end #assert_post_conditions
end #ClassMethods
end #Assertions
require_relative '../../test/assertions/default_assertions.rb'
include Examples
include Assertions
extend Assertions::ClassMethods
include GenericJsons::Assertions
extend GenericJsons::Assertions::ClassMethods
end #Definitions

class Transforms
include NoDB
extend NoDB::ClassMethods
include GenericJsons
extend GenericJsons::ClassMethods
include GenericJsons::Assertions
extend GenericJsons::Assertions::ClassMethods
module Constants
include OpenTaxFormFiller::Constants
Open_tax_filler_directory="../OpenTaxFormFiller/#{Default_tax_year}"
Input_filenames="#{Open_tax_filler_directory}/transform/Federal/f*.json"
Data_source_directory='test/data_sources'
OTF_SQL_dump_filename="#{Data_source_directory}/OTF_SQL_dump_#{Default_tax_year}.sql"
Symbol_pattern='^ ?([-A-Za-z0-9?]+)'
Symbol_regexp=/#{Symbol_pattern}/
end #Constants
include Constants
def self.input_file_names
	Input_filenames
end #input_file_names
# returns array of hashes
def self.parse(acquisition) 
	json=JSON[acquisition]
	entries=[]
	json['fields'].each_pair do |key, value|
		flat={}
		flat[:form]=json['form']
		flat[:title]=json['title']
		flat[:year]=json['year']
		flat[:pdfSum]=json['pdfSum']
		flat[:line]=key
		flat[:type]=value
		entries.push(flat)
	end #each_pair
	entries
end #parse
def self.all
	All
end #all
module Examples
Simple_acquisition="{\"year\":2012,\"form\":\"f1040\",\"fields\":[{}]}"

All=Transforms.all_initialize
end #Examples
require_relative '../../test/assertions/default_assertions.rb'

module Assertions
include Test::Unit::Assertions
extend Test::Unit::Assertions
def assert_invariant
	assert_instance_of(Definitions, self)
#	assert_scope_path(:DefaultAssertions, :ClassMethods)
	assert_includes(self.methods, :insert_sql)
	explain_assert_respond_to(self, :insert_sql)
	assert_respond_to(self, :insert_sql)
	assert_equal([:form, :year, :line, :type], self.keys, self.inspect)
	assert_include(["Amount", "Choice", "Text", "Number", "Integer", "Percent"], self[:type])
end #assert_invariant
module ClassMethods
include Constants
include Examples
include Test::Unit::Assertions
extend Test::Unit::Assertions
include DefaultAssertions::ClassMethods
def assert_pre_conditions
#	assert_scope_path(:DefaultAssertions, :ClassMethods)
	assert_include(included_modules, NoDB, "")
end #assert_pre_conditions
def assert_post_conditions
#	assert_constant_instance_respond_to(:DefaultAssertions, :ClassMethods, :value_of_example?) #, "In assert_post_conditions calling assert_constant_instance_respond_to"
	Examples.constants.each do |name|
		example_acquisition=Definitions.value_of_example?(name)
	end #each
#hit	fail "end of CLASS assert_post_conditions"
end #assert_post_conditions
end #ClassMethods
end #Assertions
require_relative '../../test/assertions/default_assertions.rb'
include Examples
include Assertions
extend Assertions::ClassMethods
include GenericJsons::Assertions
extend GenericJsons::Assertions::ClassMethods
end #Transforms

class Pjsons
include NoDB
extend NoDB::ClassMethods
include GenericFiles
extend GenericFiles::ClassMethods
include GenericFiles::Assertions
extend GenericFiles::Assertions::ClassMethods
module Constants
include OpenTaxFormFiller::Constants
Open_tax_filler_directory="../OpenTaxFormFiller/#{Default_tax_year}"
Input_filenames="#{Open_tax_filler_directory}/transform/Federal/f*.json"
Data_source_directory='test/data_sources'
OTF_SQL_dump_filename="#{Data_source_directory}/OTF_SQL_dump_#{Default_tax_year}.sql"
Symbol_pattern='^ ?([-A-Za-z0-9?]+)'
Symbol_regexp=/#{Symbol_pattern}/
end #Constants
include Constants
def self.input_file_names
	"#{Open_tax_filler_directory}/field_dump/Federal/f*.pjson"
end #input_file_names
# returns array of hashes
def self.parse(acquisition) 
	json=JSON[acquisition]
	entries=[]
	json['fields'].each_pair do |key, value|
		flat={}
		flat[:form]=json['form']
		flat[:title]=json['title']
		flat[:year]=json['year']
		flat[:pdfSum]=json['pdfSum']
		flat[:line]=key
		flat[:type]=value
		entries.push(flat)
	end #each_pair
	entries
end #parse
def self.all
	All
end #all
def self.coarse_filter
	raw_acquisitions.select do |acquisition|
		Type_regexp.match(acquisition) && Description_regexp.match(acquisition)
	end #select
end #coarse_filter
module Examples
Simple_acquisition="{\"year\":2012,\"form\":\"f1040\",\"fields\":[{}]}"

All=Pjsons.all_initialize
end #Examples
require_relative '../../test/assertions/default_assertions.rb'

module Assertions
include Test::Unit::Assertions
extend Test::Unit::Assertions
def assert_invariant
	assert_instance_of(Definitions, self)
#	assert_scope_path(:DefaultAssertions, :ClassMethods)
	assert_includes(self.methods, :insert_sql)
	explain_assert_respond_to(self, :insert_sql)
	assert_respond_to(self, :insert_sql)
	assert_equal([:form, :year, :line, :type], self.keys, self.inspect)
	assert_include(["Amount", "Choice", "Text", "Number", "Integer", "Percent"], self[:type])
end #assert_invariant
module ClassMethods
include Constants
include Examples
include Test::Unit::Assertions
extend Test::Unit::Assertions
include DefaultAssertions::ClassMethods
def assert_pre_conditions
#	assert_scope_path(:DefaultAssertions, :ClassMethods)
	assert_include(included_modules, NoDB, "")
end #assert_pre_conditions
def assert_post_conditions
#	assert_constant_instance_respond_to(:DefaultAssertions, :ClassMethods, :value_of_example?) #, "In assert_post_conditions calling assert_constant_instance_respond_to"
	Examples.constants.each do |name|
		example_acquisition=Definitions.value_of_example?(name)
	end #each
#hit	fail "end of CLASS assert_post_conditions"
end #assert_post_conditions
end #ClassMethods
end #Assertions
require_relative '../../test/assertions/default_assertions.rb'
include Examples
include Assertions
extend Assertions::ClassMethods
include GenericFiles::Assertions
extend GenericFiles::Assertions::ClassMethods
end #Pjsons
end #OpenTaxFormFiller
