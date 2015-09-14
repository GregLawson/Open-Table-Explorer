###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/file_pattern.rb'
require 'virtus'
class Unit
module ClassMethods
def new_from_path(path)
	library_name = FilePattern.path2model_name?(path)
	Unit.new(library_name, FilePattern.project_root_dir?(path))
end #new_from_path
def unit_names?(files)
	files.map do |f|
		FilePattern.unit_base_name?(f).to_s
	end #map
end #unit_names?
def patterned_files
	FilePattern.pathnames?('*').map do |globs|
		Dir[globs]
	end.flatten # map
end # patterned_files
def all
	patterned_files.map do |path|
		unit = new_from_path(path)
	end.uniq # map
end # all
def all_basenames
	Unit.all.map {|u| u.model_basename}.uniq.sort
end # all_basenames
end #ClassMethods
extend ClassMethods

attr_reader :model_basename,  :model_class_name, :project_root_dir, :edit_files, :missing_files
def initialize(model_class_name = FilePattern.path2model_name?, 
	project_root_dir = FilePattern.project_root_dir?)
	message="model_class is nil\n$0=#{$0}\n model_class_name=#{model_class_name}\nFile.expand_path=File.expand_path(#{File.expand_path($0)}"
	if model_class_name.nil? then
		warn message if model_class_name.nil?
		@model_class_name=nil
	else
		@model_class_name=model_class_name.to_sym
	end #if
	if project_root_dir.nil? then
		@project_root_dir='' #empty string not nil
	else
		@project_root_dir= project_root_dir  #not nil
	end #
	@model_basename=@model_class_name.to_s.underscore.to_sym
	raise "@model_basename" if @model_basename.nil?
	@edit_files, not_files=pathnames?.partition do |p|
		File.file?(p)
	end #partition
	@directories, @missing_files=not_files.partition do |p|
		File.exist?(p)
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
def pathname_pattern?(file_spec, test = nil)
	raise "project_root_dir" if @project_root_dir.nil?
	file_pattern=FilePattern.find_by_name(file_spec)
	raise "FilePattern.find_by_name(#{file_spec.inspect})=#{file_pattern.inspect} not found" if file_pattern.nil?
	raise "@model_basename" if @model_basename.nil?
	if test.nil? then
		unit_base_name = @model_basename
	else
		unit_base_name = @model_basename + '_' + test
	end # if
	@project_root_dir + FilePattern.path?(file_pattern, unit_base_name)
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
	pathname_pattern?(:data_sources_dir)
	@project_root_dir+'test/data_sources/' + @model_basename.to_s
end #data_sources_directory
#  Initially the number of files for the model
def pathnames?
#	[assertions_test_pathname?, assertions_pathname?, model_test_pathname?, model_pathname?]
	raise "project_root_dir" if @project_root_dir.nil?
	raise "@model_basename" if @model_basename.nil?
	FilePattern::Patterns.map do |pattern|
		@project_root_dir + FilePattern.path?(pattern, @model_basename)
	end # map
end #pathnames
module Constants
Executable = Unit.new_from_path($PROGRAM_NAME)
end #Constants
include Constants
def patterned_files
	patterned_files = FilePattern.pathnames?(@model_basename).map do |globs|
		Dir[globs]
	end.flatten # map
end # patterned_files
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
def functional_parallelism(edit_files=@edit_files)
	[
	[model_pathname?, model_test_pathname?],
	[assertions_pathname?, model_test_pathname?],
	[model_test_pathname?, pathname_pattern?(:integration_test)],
	[assertions_pathname?, assertions_test_pathname?]
	].select do |fp|
		fp-edit_files==[] # files must exist to be edited?
	end #map
end #functional_parallelism
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
def test_class_name
	@model_class_name.to_s + 'Test'
end # test_class
def test_class
	eval(test_class_name)
end # test_class
def create_test_class
	anonomous_test_class = Class.new(TestCase) do
		extend(RubyAssertions)
		include(RubyAssertions)
	end # NewTestClass
	Object.const_set(test_class_name, anonomous_test_class)
end # create_test_class
end # Unit
class Example
module ClassMethods
def find_all_in_class(containing_class)
	if containing_class.constants.include?(:Examples) then # if there is no module Examples in unit
		[]
	else
		containing_class::Examples.constants.map do |example_name|
			example = Example.new(containing_class: containing_class, example_constant_name: example_name)
		end # map
	end # if
end # find_all_in_class
def find_by_class(containing_class, value_class)
	find_all_in_class(containing_class).select {|example| example.class == value_class}
end # find_by_class
end # ClassMethods
extend ClassMethods
include Virtus.model
	attribute :containing_class, Class
	attribute :example_constant_name, String
def fully_qualified_name
	@containing_class.name.to_s + '::Examples::' + @example_constant_name.to_s
end # fully_qualified_name
def value
	eval(fully_qualified_name)
end # value
end # Example
