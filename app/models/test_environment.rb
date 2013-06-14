###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'active_support/all'
require 'test/unit'
module TestIntrospection
def model_basename?
	File.basename($0, '.rb')[0..-6]
end #model_basename
def class_name?
	model_basename?.classify
end #class_name
def name_of_test?
	model_basename?.classify.to_s+'Test'
end #name_of_test
class TestEnvironment
attr_reader :model_basename, :test_class_name
def initialize(test_class_name=class_name?, model_class_name=nil)
	@test_class_name=test_class_name.to_sym
	if model_class_name.nil? then
		@model_class_name=@test_class_name.to_s.sub(/Test$/, '').sub(/Assertions$/, '').to_sym
	else
		@model_class_name=model_class_name
	end #if
	@model_basename=@model_class_name.to_s.tableize.singularize.to_sym
#	@files_root= # reltive to working directory not file as in require_relative
end #initialize
def inspect
	existing, missing = pathnames?.partition do |p|
		File.exists?(p)
	end #partition
	ret=" test for model class "+@model_class_name.to_s+"assertions_test_pathname="+assertions_test_pathname?.inspect
	ret+="existing files=#{existing.inspect} and missing files=#{missing.inspect}"
end #inspect
def model_pathname?
	"app/models/"+@model_basename.to_s+".rb"
end #model_pathname?
def model_test_pathname?
	"test/unit/"+@model_basename.to_s+"_test.rb"
end #model_test_pathname?
def assertions_pathname?
	"test/assertions/"+@model_basename.to_s+"_assertions.rb"
end #assertions_pathname?
def assertions_test_pathname?
	"test/unit/"+@model_basename.to_s+"_assertions_test.rb"
end #assertions_test_pathname?
#  Initially the number of files for the model
def default_test_class_id?
	if File.exists?(self.assertions_test_pathname?) then
		4
	elsif File.exists?(self.assertions_pathname?) then
		3
	elsif File.exists?(self.model_test_pathname?) then
		2
	elsif File.exists?(self.model_pathname?) then
		1
	else
		0 # fewest assumptions, no files
	end #if
end #default_test_class_id
def default_tests_module_name?
	"DefaultTests"+default_test_class_id?.to_s
end #default_tests_module?
def test_case_class_name?
	"DefaultTestCase"+default_test_class_id?.to_s
end #test_case_class?
def pathnames?
	[assertions_test_pathname?, assertions_pathname?, model_test_pathname?, self.model_pathname?]
end #pathnames
def absolute_pathnames?
	pathnames?.map {|p| File.expand_path(p)}
end #absolute_pathnames
def pathname_existance?
	absolute_pathnames?.map {|p| File.exists?(p) ? 1 : 0}
end #pathname_existance
def model_class?
	eval(@model_class_name)
end #model_class
def model_name?
	@model_class_name
end #model_name?
module Examples
UnboundedFixnumTestEnvironment=TestEnvironment.new(:UnboundedFixnum)
end #Examples
module Assertions
module ClassMethods
include Test::Unit::Assertions
end #ClassMethods

include Test::Unit::Assertions
# conditions that are always true (at least atomically)
def assert_invariant
end # class_assert_invariant
# conditions true while class is being defined
# assertions true after class (and nested module Examples) is defined
def assert_pre_conditions
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions
end #class_assert_post_conditions


end #Assertions
include Assertions
extend Assertions::ClassMethods
end #TestEnvironment
# methods to extract model, class from TestCase subclass
def name_of_test?
	self.class.name
end #name_of_test?
# Extract model name from test name if Rails-like naming convention is followed
def model_name?
	name_of_test?.sub(/Test$/, '').sub(/Assertions$/, '').to_sym
end #model_name?
def model_class?
	begin
		eval(model_name?.to_s)
	rescue
		nil
	end #begin rescue
end #model_class?
def table_name?
	model_name?.to_s.tableize
end #table_name?
def names_of_tests?
	self.methods(true).select do |m|
		m.match(/^test(_class)?_assert_(invariant|pre_conditions|post_conditions)/) 
	end #map
end #names_of_tests?
end #TestIntrospection
include TestIntrospection
TE=TestIntrospection::TestEnvironment.new
DefaultTests=eval(TE.default_tests_module_name?)
TestCase=eval(TE.test_case_class_name?)
