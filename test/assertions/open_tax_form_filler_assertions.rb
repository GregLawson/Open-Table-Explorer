###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/generic_file.rb'
require_relative '../../app/models/open_tax_form_filler.rb'
module OpenTaxFormFiller

class Definitions
#require_relative '../../test/assertions/default_assertions.rb'

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
extend Assertions::ClassMethods
include GenericJsons::Assertions
extend GenericJsons::Assertions::ClassMethods
end #Transforms

class Pjsons
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
#include Test::Unit::Assertions
extend Test::Unit::Assertions
include DefaultAssertions::ClassMethods
def assert_match_regexp_array(acquisition, combination_indices=Array.new(full_regexp_array.size){|i| i})
	rest=acquisition # save for error reporting context
	regexp_string=full_regexp_array[combination_indices[0]]
	assert_match(/#{regexp_string}/, acquisition)
	combination_indices.each_cons(2) do |pair|
		if pair[0]+1==pair[1] then # consecutive match
			added_regexp=full_regexp_array[pair[1]]
		else #mismatch deleted
			added_regexp="(?<error_#{pair[0]}>.*)"
		end #if
		regexp_string+=added_regexp
		if matchData=/#{regexp_string}/.match(acquisition) then
			rest=matchData.post_match
		else
			message="regexp_string=/#{regexp_string}/ did not match acquisition"
			message+="\n#{acquisition[0..100]}"
			message="\npair=/#{pair}" 
			message+="\nadding /#{added_regexp}/ did not match '#{rest[0..100]}'"
			raise message
		end #if
	end #each_cons
	regexp=Regexp.new(regexp_string)
	assert_match(/#{regexp_string}/, acquisition)
	matchData=regexp.match(acquisition)
	assert_not_nil(matchData)
	match_regexp_array(combination_indices, acquisition)
end #match_regexp_array
def assert_parsed
	parsed=parse
	assert_not_empty(parsed)
	parsed.each do |hash|
		assert_equal([:field_number, :form_type, :page, :path, :field_designator], hash.keys)
	end #each
	assert_operator(parsed.size, :>, raw_acquisitions.size)
#	puts parsed.inspect
end #assert_parsed
# minimal assertions (with good error messaages) to allow:
# 1) class definition to execute (often Example constant setting requires initialize method to execute without error)
# 2) class requirements to be documented
def assert_pre_conditions
#	assert_scope_path(:DefaultAssertions, :ClassMethods)
	assert_include(included_modules, NoDB, "")
#	assert_equal(MiniTest::Assertion, self)
	full_regexp_array.each do |regexp_string|
		assert_not_nil(RegexpParse.regexp_rescued(regexp_string), regexp_string)
	end #each
	assert_not_empty(raw_acquisitions)
end #assert_pre_conditions
def assert_post_conditions
#	assert_constant_instance_respond_to(:DefaultAssertions, :ClassMethods, :value_of_example?) #, "In assert_post_conditions calling assert_constant_instance_respond_to"
	Examples.constants.each do |name|
		example_acquisition=Definitions.value_of_example?(name)
	end #each
#hit	fail "end of CLASS assert_post_conditions"
	assert_operator(raw_acquisitions.size, :==, 2080)
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
