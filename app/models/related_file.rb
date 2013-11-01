###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/file_pattern.rb'
class RelatedFile
module Constants
end #Constants
include Constants
module ClassMethods
def new_from_path?(path)
	library_name=FilePattern.path2model_name?(path)
	RelatedFile.new(library_name, FilePattern.project_root_dir?(path))
end #new_from_path?
end #ClassMethods
extend ClassMethods
attr_reader :model_basename,  :model_class_name, :project_root_dir, :edit_files, :missing_files
def initialize(model_class_name=FilePattern.path2model_name?, project_root_dir=FilePattern.project_root_dir?)
	message="model_class is nil\n$0=#{$0}\n model_class_name=#{model_class_name}\nFile.expand_path=File.expand_path(#{File.expand_path($0)}"
	raise message if model_class_name.nil?
	@model_class_name=model_class_name.to_sym
	if project_root_dir.nil? then
		@project_root_dir='' #empty string not nil
	else
		@project_root_dir= project_root_dir  #not nil
	end #
	@model_basename=@model_class_name.to_s.tableize.singularize
	raise "@model_basename" if @model_basename.nil?
	@edit_files, @missing_files=pathnames?.partition do |p|
		File.exists?(p)
	end #partition
end #initialize
# Equality of defining content
def ==(other)
	if model_class_name==other.model_class_name && project_root_dir==other.project_root_dir then
		true
	else
		false
	end #if
end #==
def pathname_pattern?(file_spec)
	raise "project_root_dir" if @project_root_dir.nil?
	raise "FilePattern.find_by_name(file_spec)[:sub_directory]" if FilePattern.find_by_name(file_spec)[:sub_directory].nil?
	raise "@model_basename" if @model_basename.nil?
	raise "FilePattern.find_by_name(file_spec)[:suffix]" if FilePattern.find_by_name(file_spec)[:suffix].nil?
	@project_root_dir+FilePattern.find_by_name(file_spec)[:sub_directory]+@model_basename.to_s+FilePattern.find_by_name(file_spec)[:suffix]
end #pathname_pattern
def model_pathname?
	pathname_pattern?(:model)
end #model_pathname?
def model_test_pathname?
	pathname_pattern?(:test)
end #model_test_pathname?
def assertions_pathname?
	pathname_pattern?(:assertions)
end #assertions_pathname?
def assertions_test_pathname?
	pathname_pattern?(:assertions_test)
end #assertions_test_pathname?
def data_sources_directory?
	@project_root_dir+'test/data_sources/'
end #data_sources_directory
#  Initially the number of files for the model
def pathnames?
#	[assertions_test_pathname?, assertions_pathname?, model_test_pathname?, model_pathname?]
	raise "project_root_dir" if @project_root_dir.nil?
	raise "@model_basename" if @model_basename.nil?
	FilePattern::All.map do |p|
		pathname_pattern?(p[:name])
	end #
end #pathnames
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
def tested_files(executable)
	if executable==pathname_pattern?(:script) then # script only
		[model_pathname?, executable]
	else case default_test_class_id? # test files
	when 0 then [model_test_pathname?]
	when 1 then [model_test_pathname?]
	when 2 then [model_pathname?, executable]
	when 3 then [model_pathname?, model_test_pathname?, assertions_pathname?]
	when 4 then [model_pathname?, model_test_pathname?, assertions_pathname?, assertions_test_pathname?]
	end #case
	end-@missing_files #if
end #tested_files
def model_class?
	eval(@model_class_name.to_s)
end #model_class
def model_name?
	@model_class_name
end #model_name?
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
# conditions that are always true (at least atomically)
def assert_invariant
#	fail "end of assert_invariant "
end # class_assert_invariant
# conditions true while class is being defined
def assert_pre_conditions
	assert_respond_to(FilePattern, :project_root_dir?)
	assert_module_included(self, FilePattern::Assertions)
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions
	assert_equal(TE, FilePattern::Examples::SELF)
end #class_assert_post_conditions
end #ClassMethods
module KernelMethods
end #KernelMethods
# conditions that are always true (at least atomically)
def assert_invariant
	fail "end of assert_invariant "
end #assert_invariant
# conditions true while class is being defined
# assertions true after class (and nested module Examples) is defined
def assert_pre_conditions
	assert_not_empty(@model_class_name, "test_class_name")
	assert_not_empty(@model_basename, "model_basename")
#	fail "end ofassert_pre_conditions "
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions(message='')
	message+="\ndefault FilePattern.project_root_dir?=#{FilePattern.project_root_dir?.inspect}"
	assert_not_empty(@project_root_dir, message)
end #assert_post_conditions
def assert_tested_files(executable, file_patterns)
	tested_file_patterns=tested_files(executable).map do |f|
		FilePatter.find_by_path(f)[:name]
	end #map
	assert_equal(file_patterns, tested_file_patterns)
end #assert_tested_files
def assert_default_test_class_id(expected_id, message='')
	message+="self=#{self.inspect}"
	assert_equal(expected_id, default_test_class_id?, message+caller_lines)
end #default_test_class_id

end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
UnboundedFixnumRelatedFile=RelatedFile.new(:UnboundedFixnum)
SELF=RelatedFile.new #defaults to this unit
end #Examples
include Examples
end #RelatedFile
