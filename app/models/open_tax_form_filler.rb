###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/generic_file.rb'
require_relative '../../app/models/no_db.rb'
class OpenTaxFormFiller
include NoDB
extend NoDB::ClassMethods
module Constants
Default_tax_year=2012
Open_tax_filler_directory="../OpenTaxFormFiller/#{Default_tax_year}"
OTF_definition_filenames="#{Open_tax_filler_directory}/definition/Federal/f*.json"
Data_source_directory='test/data_sources'
OTF_SQL_dump_filename="#{Data_source_directory}/OTF_SQL_dump_{Default_tax_year}.sql"
Symbol_pattern='^ ?([-A-Za-z0-9?]+)'
Delimiter='\s+'
Specific_types=['\?\?', '0', ';', '0\s+;', 'Yes']
Type_pattern='(\s+|'+Specific_types.map{|a| '('+Delimiter+'('+a+')'+Delimiter+')'}.join('|')+')'
Description_pattern='\{(.+)\}'
Symbol_regexp=/#{Symbol_pattern}/
Type_regexp=/#{Symbol_pattern}#{Type_pattern}/
Description_regexp=/#{Description_pattern}/
Full_regexp=/#{Symbol_pattern}#{Type_pattern}#{Description_pattern}/
end #Constants
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
		OpenTaxFormFiller.new(hash, [String, Fixnum, String, String])
	end #map
end #parse
def assert_json_string(acquisition)
	assert_not_nil(acquisition)
	assert_instance_of(String, acquisition)
	json=JSON[acquisition]
	assert_instance_of(Hash, json)
end #assert_json_string
def self.raw_acquisitions
	all_files=Dir[OTF_definition_filenames]
	all_files.map do |filename|
		json=JSON[IO.read(filename)]
		entries=json['fields'].each_pair do |key, value|
			flat={}
			flat[:form]=json['form']
			flat[:year]=json['year']
			flat[:line]=key
			flat[:type]=value
			flat
		end #each_pair
		entries
	end.compact # map
end #raw_acquisitions
def self.coarse_filter
	raw_acquisitions.select do |acquisition|
		Type_regexp.match(acquisition) && Description_regexp.match(acquisition)
	end #select
end #coarse_filter
def self.coarse_rejections
	raw_acquisitions.select do |acquisition|
		!(Type_regexp.match(acquisition) && Description_regexp.match(acquisition))
	end #select
end #coarse_rejections
def self.all(tax_year=Default_tax_year)
	coarse_filter.map do |r| #map
		matchData=Full_regexp.match(r)
		if matchData then
			otff=parse(r, Full_regexp)
			otff[:tax_year]=tax_year
			otff
		else
			nil
		end #if
	end.compact #map
end #all
def self.fine_rejections
	coarse_filter.select do |r| #map
		!Full_regexp.match(r)
	end #select
end #fine_rejections
module Examples
Simple_acquisition="{\"year\":2012,\"form\":\"f1040\",\"fields\":[{}]}"


end #Examples
require_relative '../../test/assertions/default_assertions.rb'

module Assertions
include Test::Unit::Assertions
extend Test::Unit::Assertions
def assert_pre_conditions
		assert_instance_of(OpenTaxFormFiller, self)
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
include OpenTaxFormFiller::Constants
include OpenTaxFormFiller::Examples
include Test::Unit::Assertions
extend Test::Unit::Assertions
include DefaultAssertions::ClassMethods
def assert_pre_conditions
	assert_scope_path(:DefaultAssertions, :ClassMethods)
	assert_include(included_modules, NoDB, "")
end #assert_pre_conditions
def assert_post_conditions
#	assert_constant_instance_respond_to(:DefaultAssertions, :ClassMethods, :value_of_example?) #, "In assert_post_conditions calling assert_constant_instance_respond_to"
	Examples.constants.each do |name|
		example_acquisition=OpenTaxFormFiller.value_of_example?(name)
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
def assert_json_string(acquisition)
	assert_not_nil(acquisition)
	assert_instance_of(String, acquisition)
	json=JSON[acquisition]
	assert_instance_of(Hash, json)
end #assert_json_string
end #ClassMethods
end #Assertions
require_relative '../../test/assertions/default_assertions.rb'
include Assertions
include Examples
include Constants
extend Assertions::ClassMethods
end #OpenTaxFormFiller

