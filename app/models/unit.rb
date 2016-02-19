###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson                                      
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/file_pattern.rb'
require 'virtus'
module FileUnit
def edit_files
	pathnames?.select do |p|
		File.file?(p)
	end # select
end # edit_files
def not_files
	pathnames?.select do |p|
		!File.file?(p)
	end # select
end # not_files
def directories
	not_files.select do |p|
		File.file?(p)
	end # directories
end # directories
def missing_files
	not_files.select do |p|
		!File.exist?(p)
	end # select
end # missing_files
module ClassMethods
def new_from_path(path)
	library_name = FilePattern.unit_base_name?(path)
	self.new(model_basename: library_name, project_root_dir: FilePattern.project_root_dir?(path))
end # new_from_path
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
def data_source_directories
	'test/data_sources/'
end #data_source_directory?
end #ClassMethods
extend ClassMethods

def data_source_directory?
	ret = @project_root_dir + Unit.data_source_directories + @model_basename.to_s + '/'

	Pathname.new(ret).mkpath
	ret
end #data_source_directory?
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
def data_sources_directory?
	pathname_pattern?(:data_sources_dir)
	@project_root_dir+'test/data_sources/' + @model_basename.to_s
end #data_sources_directory
#  Initially the number of files for the model
def pathnames?
#	[assertions_test_pathname?, assertions_pathname?, pathname_pattern?(:unit), pathname_pattern?(:model)]
	raise "project_root_dir" if @project_root_dir.nil?
	raise "@model_basename" if @model_basename.nil?
	FilePattern::Patterns.map do |pattern|
		@project_root_dir + FilePattern.path?(pattern, @model_basename)
	end # map
end #pathnames
def patterned_files
	patterned_files = FilePattern.pathnames?(@model_basename).map do |globs|
		Dir[globs]
	end.flatten # map
end # patterned_files
def assertions_pathname?
	pathname_pattern?(:assertions)
end #assertions_pathname?
def assertions_test_pathname?
	pathname_pattern?(:assertions_test)
end #assertions_test_pathname?
def default_test_class_id?
	if File.exists?(self.assertions_test_pathname?) then
		4
	elsif File.exists?(self.assertions_pathname?) then
		3
	elsif File.exists?(self.pathname_pattern?(:model)) then
		2
	elsif File.exists?(self.pathname_pattern?(:unit)) then
		1
	else
		0 # fewest assumptions, no files
	end #if
end #default_test_class_id
def functional_parallelism(edit_files)
	[
	[pathname_pattern?(:model), pathname_pattern?(:unit)],
	[assertions_pathname?, pathname_pattern?(:unit)],
	[pathname_pattern?(:unit), pathname_pattern?(:integration_test)],
	[assertions_pathname?, assertions_test_pathname?]
	].select do |fp|
		fp - edit_files==[] # files must exist to be edited?
	end #map
end #functional_parallelism
def tested_files(executable)
	if executable==pathname_pattern?(:script) then # script only
		[pathname_pattern?(:model), executable]
	else case default_test_class_id? # test files
	when 0 then [pathname_pattern?(:unit)]
	when 1 then [pathname_pattern?(:unit)]
	when 2 then [pathname_pattern?(:model), executable]
	when 3 then [pathname_pattern?(:model), pathname_pattern?(:unit), assertions_pathname?]
	when 4 then [pathname_pattern?(:model), pathname_pattern?(:unit), assertions_pathname?, assertions_test_pathname?]
	end #case
	end - missing_files #if
end #tested_files
end # FileUnit

module RubyClassUnit # class not in expected file
end # RubyClassUnit

class Unit # base class
# Fully reconfigurable via FilePattern
# FileUnit or RubyClassUnit?
  include Virtus.value_object
  values do
	attribute :model_basename, Symbol, :default => :unit
	attribute :project_root_dir, String, :default => FilePattern.project_root_dir?
	attribute :patterns, Array, :default => 	FilePattern::Patterns
end # values
include FileUnit
extend FileUnit::ClassMethods
# Equality of defining content
#def ==(other)
#	if model_class_name==other.model_class_name && project_root_dir==other.project_root_dir then
#		true
#	else
#		false
#	end #if
#end #==
module Constants
Executable = Unit.new_from_path($PROGRAM_NAME)
end #Constants
include Constants
end # Unit

class RubyUnit < Unit
  include Virtus.value_object
  values do
	attribute :model_class_name, Symbol, :default => lambda { |unit, attribute| unit.model_basename.to_s.classify }
end # values
extend FileUnit::ClassMethods
def default_tests_module_name?
	"DefaultTests"+default_test_class_id?.to_s
end #default_tests_module?
def test_case_class_name?
	"DefaultTestCase"+default_test_class_id?.to_s
end #test_case_class?
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
module Constants
Executable = RubyUnit.new_from_path($PROGRAM_NAME)
end #Constants
include Constants
end # RubyUnit

class RailsishRubyUnit < RubyUnit
# Follow Rails naming colnventions, but not require all of Rails
extend FileUnit::ClassMethods
module Constants
Executable = RailsishRubyUnit.new_from_path($PROGRAM_NAME)
end #Constants
include Constants
def model_class?
	eval(@model_class_name.to_s)
end #model_class
def model_name?
	@model_class_name
end #model_name?
def model_pathname?
	pathname_pattern?(:model)
end #model_pathname?
def model_test_pathname?
	pathname_pattern?(:unit)
end #model_test_pathname?
end # RailsishRubyUnit

class RailsUnit < RailsishRubyUnit # naming conventions typical of Ruby Rails S.B. deprecated

include Virtus.model
	attribute :test_type, Symbol, :default => :unit
	attribute :singular_table, String
	attribute :plural_table, String, :default => nil
def test_file?
	case @test_type
	when :unit
		return "test/unit/#{@singular_table}_test.rb"
	when :controller
		return "test/functional/#{@plural_table}_controller_test.rb"
	else raise "Unnown @test_type=#{@test_type} for #{self.inspect}"
	end #case
end #test_file?
def unit?
	Unit.new(@singular_table)
end # unit?
module Examples
#include Constants
Unit_executable = RailsUnit.new(:test_type => :unit)
Plural_executable = RailsUnit.new({:test_type => :unit, :plural_table => 'test_runs'})
Singular_executable = RailsUnit.new(:test_type => :unit,  :singular_table => 'test_run')
Odd_plural_executable = RailsUnit.new(:test_type => :unit, :singular_table => :code_base, :plural_table => :code_bases, :test => nil)
end # Examples
end # RailsUnit

class Example
module ClassMethods
def find_all_in_class(containing_class)
	if containing_class.constants.include?(:Examples) then # if there is no module Examples in unit
		containing_class::Examples.constants.map do |example_name|
			example = Example.new(containing_class: containing_class, example_constant_name: example_name)
		end # map
	else
		[]
	end # if
end # find_all_in_class
def find_by_class(containing_class, value_class)
	find_all_in_class(containing_class).select {|example| example.value.class == value_class}
end # find_by_class
end # ClassMethods
extend ClassMethods
include Virtus.model
	attribute :containing_class, Class
	attribute :example_constant_name, String
def ==(other)
	@containing_class == other.containing_class && @example_constant_name == other.example_constant_name
end # ==
def fully_qualified_name
	@containing_class.name.to_s + '::Examples::' + @example_constant_name.to_s
end # fully_qualified_name
def value
	eval(fully_qualified_name)
end # value
end # Example
