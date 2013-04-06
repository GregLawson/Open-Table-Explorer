###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
module GenericFiles
include NoDB
extend NoDB::ClassMethods
module Constants
Default_tax_year=2012
end #Constants
module ClassMethods
include Constants
end #ClassMethods

end #GenericFiles

module GenericJsons
include GenericFiles
module ClassMethods
include GenericFiles::ClassMethods
def raw_acquisitions
	all_files=Dir[input_file_names]
	all_files.map do |filename|
		parse(IO.read(filename))
	end.flatten # map
end #raw_acquisitions
def coarse_filter
	raw_acquisitions
end #coarse_filter
def coarse_rejections
	[]
end #coarse_rejections
def all
	coarse_filter
end #all
def fine_rejections
	[]
end #fine_rejections
end #ClassMethods
module Assertions
def assert_pre_conditions
		assert_instance_of(Hash, self.attributes)
		assert_respond_to(self.attributes, :values)
		assert_constant_instance_respond_to(:NoDB, :insert_sql)
		assert_include(self.class.included_modules, NoDB)
#		assert_include(NoDB.methods, :insert_sql)
		assert_instance_of(Array, attributes.values)
end #assert_pre_conditions
module ClassMethods
def assert_json_string(acquisition)
	assert_not_nil(acquisition)
	assert_instance_of(String, acquisition)
	json=JSON[acquisition]
	assert_instance_of(Hash, json)
end #assert_json_string
end #ClassMethods
end #Assertions
end #GenericJson

module OpenTaxFormFiller
class Definitions
include NoDB
extend NoDB::ClassMethods
include GenericJsons
extend GenericJsons::ClassMethods
include GenericJsons::Assertions
extend GenericJsons::Assertions::ClassMethods
module Constants
Default_tax_year=2012
Open_tax_filler_directory="../OpenTaxFormFiller/#{Default_tax_year}"
Input_filenames="#{Open_tax_filler_directory}/definition/Federal/f*.json"
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
	entries.map do |hash|
		Definitions.new(hash, [String, Fixnum, String, String])
	end #map
end #parse
module Examples
Simple_acquisition="{\"year\":2012,\"form\":\"f1040\",\"fields\":[{}]}"


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
end #OpenTaxFormFiller
