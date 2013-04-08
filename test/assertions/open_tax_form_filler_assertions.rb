###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/generic_files.rb'
require_relative '../../app/models/open_tax_form_filler.rb'
module OpenTaxFormFiller

class Definitions
include NoDB
extend NoDB::ClassMethods
include GenericJsons
extend GenericJsons::ClassMethods
include GenericJsons::Assertions
extend GenericJsons::Assertions::ClassMethods
include Constants
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
#include Constants
#include Examples
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
#include Examples
#include Assertions
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
#include Constants
#include Examples
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
#include Examples
#include Assertions
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
require_relative '../../test/assertions/default_assertions.rb'

module Assertions
include Test::Unit::Assertions
extend Test::Unit::Assertions
def assert_invariant
#	assert_equal(MiniTest::Assertion, self)
	assert_instance_of(Definitions, self)
#	assert_scope_path(:DefaultAssertions, :ClassMethods)
	assert_includes(self.methods, :insert_sql)
	explain_assert_respond_to(self, :insert_sql)
	assert_respond_to(self, :insert_sql)
	assert_equal([:form, :year, :line, :type], self.keys, self.inspect)
	assert_include(["Amount", "Choice", "Text", "Number", "Integer", "Percent"], self[:type])
end #assert_invariant
module ClassMethods
#include Constants
#include Test::Unit::Assertions
extend Test::Unit::Assertions
include DefaultAssertions::ClassMethods
def assert_parseable(acquisition, strict=false)
	hash={}
	matchDatas= OpenTaxFormFiller::Pjsons::Full_regexp_array.map do |rs|
		matchData=/#{rs}/.match(acquisition)
		if matchData then
			matchData.names.map do |n|
				hash[n.to_sym]=matchData[n]
			end #map
			acquisition=matchData.post_match
		else
			if strict then
				assert_not_nil(matchData)
				assert_not_nil(matchData.pre_match)
			end #if
		end #if
		matchData
	end #map
	assert_not_equal(0, hash.size, hash)
	puts "hash=#{hash.inspect}"
end #assert_parseable
def assert_parsed
	parsed=parse
	assert_not_empty(parsed)
	parsed.each do |hash|
		assert_equal([:field_number, :form_type, :page, :path, :field_designator], hash.keys)
	end #each
	assert_operator(parsed.size, :>, raw_acquisitions.size)
#	puts parsed.inspect
end #assert_parsed
def assert_pre_conditions
#	assert_scope_path(:DefaultAssertions, :ClassMethods)
	assert_include(included_modules, NoDB, "")
#	assert_equal(MiniTest::Assertion, self)
	parsed= raw_acquisitions.map do |acquisition|
		hash={}
		matchDatas= OpenTaxFormFiller::Pjsons::Full_regexp_array.map do |rs|
			matchData=/#{rs}/.match(acquisition)
			matchData.names.map do |n|
				hash[n.to_sym]=matchData[n]
			end #map
			acquisition=matchData.post_match
			matchData
		end #first
		puts "hash=#{hash.inspect}"
		hash
	end #select
	assert_parseable(raw_acquisitions[0])
	assert_not_empty(parsed)
	assert_not_empty(coarse_filter)
	raw_acquisitions.map do |acquisition|
		assert_parseable(acquisition)	
	end #map
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
include Assertions
extend Assertions::ClassMethods
include GenericFiles::Assertions
extend GenericFiles::Assertions::ClassMethods
end #Pjsons
end #OpenTaxFormFiller
