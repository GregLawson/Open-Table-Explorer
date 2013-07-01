###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'active_support/all'
require 'test/unit'
require_relative 'test_introspection.rb'
class TestEnvironment
include TestIntrospection::Constants
extend TestIntrospection
attr_reader :model_basename,  :model_class_name, :project_root_dir, :edit_files, :missing_files
def initialize(model_class_name=TestEnvironment.path2model_name?, project_root_dir=TestEnvironment.project_root_dir?)
	@model_class_name=model_class_name.to_sym
	@project_root_dir=project_root_dir
	@model_basename=@model_class_name.to_s.tableize.singularize
	@edit_files, @missing_files=pathnames?.partition do |p|
		File.exists?(p)
	end #partition
end #initialize
# Equality of content
def ==(other)
	if model_class_name==other.model_class_name && project_root_dir==other.project_root_dir then
		true
	else
		false
	end #if
end #==
#def inspect
#	existing, missing = pathnames?.partition do |p|
#		File.exists?(p)
#	end #partition
#	ret=" test for model class "+@model_class_name.to_s+" assertions_test_pathname="
#	ret+=assertions_test_pathname?.inspect
#	ret+="\nexisting files=#{existing.inspect} \nand missing files=#{missing.inspect}"
#end #inspect
def model_pathname?
	@project_root_dir+TestEnvironment.lookup(:model, :sub_directory)+@model_basename.to_s+TestEnvironment.lookup(:model, :suffix)
end #model_pathname?
def model_test_pathname?
	@project_root_dir+TestEnvironment.lookup(:test, :sub_directory)+@model_basename.to_s+TestEnvironment.lookup(:test, :suffix)
end #model_test_pathname?
def assertions_pathname?
	@project_root_dir+TestEnvironment.lookup(:assertions, :sub_directory)+@model_basename.to_s+TestEnvironment.lookup(:assertions, :suffix)
end #assertions_pathname?
def assertions_test_pathname?
	@project_root_dir+TestEnvironment.lookup(:assertions_test, :sub_directory)+@model_basename.to_s+TestEnvironment.lookup(:assertions_test, :suffix)
end #assertions_test_pathname?
def data_sources_directory?
	@project_root_dir+'test/data_sources'
end #data_sources_directory
#  Initially the number of files for the model
def default_test_class_id?
	if File.exists?(self.assertions_test_pathname?) then
		4
	elsif File.exists?(self.assertions_pathname?) then
		3
	elsif File.exists?(self.model_pathname?) then
		2
	elsif File.exists?(self.model_test_pathname?) then
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
SELF=TestEnvironment.new
end #Examples
module Assertions
module ClassMethods
include Test::Unit::Assertions
# conditions that are always true (at least atomically)
def assert_invariant
#	fail "end of assert_invariant "
end # class_assert_invariant
# conditions true while class is being defined
def assert_pre_conditions
	assert_respond_to(TestEnvironment, :project_root_dir?)
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions
	assert_equal(TE, TestIntrospection::TestEnvironment::Examples::SELF)
end #class_assert_post_conditions
end #ClassMethods
module KernelMethods
def assert_default_test_class_id(expected_id, class_name, message='')
	te=TestIntrospection::TestEnvironment.new(class_name)
	message+="te=#{te.inspect}"
	assert_equal(expected_id, te.default_test_class_id?, message)
end #default_test_class_id
end #KernelMethods
include Test::Unit::Assertions
# conditions that are always true (at least atomically)
def assert_invariant
	fail "end of assert_invariant "
end #assert_invariant
# conditions true while class is being defined
# assertions true after class (and nested module Examples) is defined
def assert_pre_conditions
	assert_not_empty(@test_class_name)
	assert_not_empty(@model_basename)
	fail "end ofassert_pre_conditions "
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions
end #assert_post_conditions


end #Assertions
include Assertions
extend Assertions::ClassMethods
end #TestEnvironment
