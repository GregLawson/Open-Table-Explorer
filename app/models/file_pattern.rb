###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'pathname'
require_relative 'regexp.rb'
require 'active_support/all'

class FilePattern # <  ActiveSupport::HashWithIndifferentAccess
module DefinitionalConstants
# ordered from ambiguous to specific, common to rare
# TODO rename :generate to :unique, :reversable, or :unit_unique
# TODO consider making :example_file into :example_unit
Patterns = [
	{:suffix =>'.rb', :name => :model, :prefix => 'app/models/', :example_file => __FILE__, :generate => true},
	{:suffix =>'_test.rb', :name => :unit, :prefix => 'test/unit/', :example_file => $0, :generate => true},
	{:suffix =>'.rb', :name => :script, :prefix => 'script/', :example_file => 'script/work_flow.rb', :generate => true},
	{:suffix =>'_test.rb', :name => :integration_test, :prefix => 'test/integration/', :example_file => 'test/integration/release_test.rb', :generate => true}, 
	{:suffix =>'_test.rb', :name => :long_test, :prefix => 'test/long_test/', :example_file => 'test/long_test/interactive_bottleneck_test.rb', :generate => true}, 
	{:suffix =>'_assertions.rb', :name => :assertions, :prefix => 'test/assertions/', :example_file => 'test/assertions/repository_assertions.rb', :generate => true}, 
	{:suffix =>'_assertions_test.rb', :name => :assertions_test, :prefix => 'test/unit/', :example_file => 'test/unit/repository_assertions_test.rb', :generate => true},
#	{:suffix =>'.log', :name => :library_log, :prefix => 'log/unit/', :example_file => 'log/unit/repository.log', :generate => false},
	{:suffix =>'.log', :name => :unit_log, :prefix => 'log/unit/', :example_file => 'log/unit/2.2/2.2.3p173/silence/repository.log', :generate => false},
	{:suffix =>'.log', :name => :assertions_test_log, :prefix => 'log/assertions_test/', :example_file => 'log/assertions_test/2.2/2.2.3p173/silence/minimal4.log', :generate => false},
	{:suffix =>'.log', :name => :long_log, :prefix => 'log/long_test/', :example_file => 'log/long_test/2.2/2.2.3p173/silence/interactive_bottleneck.log', :generate => false},
	{:suffix =>'', :name => :data_sources_dir, :prefix => 'test/data_sources/', :example_file => 'test/data_sources/tax_form/2014/examples_and_templates/CA_540/CA_540_2014_example.txt', :generate => false},
	{:suffix =>'.log', :name => :integration_log, :prefix => 'log/integration/', :example_file => 'log/integration/2.2/2.2.3p173/silence/repository.log', :generate => false}
	]
include Regexp::Constants
Directory_delimiter = /\//
Basename_character_regexp = /[[:word:]\. -]/
Basename_regexp = Basename_character_regexp*Many
Pathname_character_regexp = /[[:word:]\. \/-]/
Relative_pathname_included_regexp  = Pathname_character_regexp*Many
Absolute_pathname_included_regexp  = Directory_delimiter*Pathname_character_regexp*Many
Relative_pathname_regexp = Start_string*Pathname_character_regexp*Many*End_string
Absolute_pathname_regexp = Start_string*Directory_delimiter*Pathname_character_regexp*Many*End_string
Relative_directory_regexp = Start_string*Pathname_character_regexp*Many*End_string
Absolute_directory_regexp = Start_string*Directory_delimiter*Pathname_character_regexp*Many*End_string
end # DefinitionalConstants
include DefinitionalConstants
module DefinitionalClassMethods
def executing_path?
	squirrely_string = $PROGRAM_NAME
	class_name = self.name.to_s
	test_name = 'test_executing_path?'
	extra_at_end = ' ' + class_name + '#' + test_name	
	extra_length = extra_at_end.length
	regexp = Relative_pathname_regexp
	squirrely_string[0..-(extra_length+2)]
end # executing_path?
def path2model_name?(path = $0)
	raise "path = #{path.inspect} must be a string" if !path.instance_of?(String)
	unit_base_name?(path).to_s.camelize.to_sym
end #path2model_name
def unit_base_name?(path = $0)
#	raise "path = #{path.inspect} must be a string" if !path.instance_of?(String)
#	path = File.expand_path(path)
	matched_pattern = find_from_path(path)
	if matched_pattern.nil? then
		nil
	else
		basename = File.basename(path.to_s)
		name_length = basename.size - matched_pattern[:suffix].size
		basename[0,name_length].to_sym
	end # if
end # unit_base_name
# searches up pathname for .git sub-directory
# returns nil if not in a git repository
def repository_dir?(path = $0)
	if File.directory?(path) then
		dirname = path
	else
		dirname = File.dirname(path)
	end #if
	begin
		git_directory = dirname+'/.git'
		if File.exist?(git_directory) then
			dirname = File.expand_path(dirname)+'/'
			done = true
		elsif dirname.size<2 then
			dirname = nil
			done = true
		else
			dirname = File.expand_path(File.dirname(dirname))+'/'
			done = false
		end #if
	end until done
	dirname
end #repository_dir?
# returns nil if file does not follow any pattern
def project_root_dir?(path = $0)
#	path = File.expand_path(path)
	matched_pattern = find_from_path(path)
	roots = DefinitionalConstants::Patterns.map do |p|
		matchData = Regexp.new(p[:prefix]).match(path.to_s)
		if matchData.nil? then
			nil
		else
			test_root = matchData.pre_match
		end #if
	end #map
	message = 'path = '+path.inspect
	message+="\nroots = "+roots.inspect
	raise message if roots.uniq.compact.size>1
	if roots.uniq.compact.size<=1 then
		roots.compact[0]
	else
		repository_dir?(path)
	end #if
end #project_root_dir
def find_by_name(name)
	DefinitionalConstants::Patterns.find do |s|
		s[:name]==name
	end #find
end #find_by_name
def match_path(pattern, path)
		pattern_match = pattern.clone
		pattern_match[:path] = path
		pattern_match[:prefix_match] = Regexp.new(pattern[:prefix]).match(path.to_s)
		pattern_match[:full_match] = pattern_match[:prefix_match] && path.to_s[-pattern[:suffix].size, pattern[:suffix].size] == pattern[:suffix]
	pattern_match
end # match_path
def match_all?(path)
#	path = File.expand_path(path)
	ret = DefinitionalConstants::Patterns.map do |p|
		match = match_path(p, path)
	end # map
	ret
end # match_all
def find_name_from_path(path)
	pattern = find_from_path(path)
	if pattern.nil? then
		nil
	else
		pattern[:name]
	end # if
end # find_name_from_path
def path?(pattern, unit_base_name)
	raise pattern.inspect if !pattern.instance_of?(Hash)
	raise pattern.inspect if !pattern[:prefix].instance_of?(String)
	raise "unit_base_name-#{unit_base_name.inspect}" if !unit_base_name.respond_to?(:to_s)
	raise "" if !pattern[:suffix].instance_of?(String)
	pattern[:prefix]+unit_base_name.to_s+pattern[:suffix]
end # path?
#returns Array of all possible pathnames for a unit_base_name
def pathnames?(unit_base_name)
	raise "unit_base_name" if unit_base_name.nil?
	DefinitionalConstants::Patterns.map do |p|
		path?(p, unit_base_name)
	end #
end #pathnames
#FilePattern.assert_pre_conditions
#assert_includes(FilePattern.included_modules, :Assertions)
#assert_pre_conditions
end # DefinitionalClassMethods
extend DefinitionalClassMethods
attr_reader :pattern, :project_root_dir, :repository_dir, :unit_base_name
def initialize(pattern,
					 unit_base_name = '*',
					 project_root_dir = Library.project_root_dir,
					 repository_dir = project_root_dir)
	raise 'initialize' unless pattern.instance_of?(Hash)
	@unit_base_name = unit_base_name
	@pattern = pattern
	@project_root_dir = project_root_dir
	@repository_dir = repository_dir
end #initialize
#def inspect
#	message = "FilePattern<instance_variables = #{instance_variables.inspect}>"
#e#nd #inspect
module Constructors # such as alternative new methods
include DefinitionalConstants
def new_from_path(path)
	raise path.inspect unless path.instance_of?(String) || path.instance_of?(Pathname)
	path = File.expand_path(path)
	pattern = FilePattern.find_from_path(path)
	FilePattern.new(pattern,
						FilePattern.unit_base_name?(path),
						FilePattern.project_root_dir?(path),
						FilePattern.repository_dir?(path))
end # new_from_path
def find_all_from_path(path)
	ret = match_all?(path).select do |p|
		p[:full_match]
	end # select
	ret
end #find_all_from_path
def find_from_path(path)
	find_all_from_path(path).last
end #find_from_path
end # Constructors
extend Constructors
def path?(unit_base_name = @basename)
	raise @pattern.inspect unless @pattern.instance_of?(Hash)
	raise @pattern.inspect if !@pattern[:prefix].instance_of?(String)
	raise "unit_base_name-#{unit_base_name.inspect}" unless unit_base_name.instance_of?(String) || unit_base_name.instance_of?(Symbol)
	raise "" if !@pattern[:suffix].instance_of?(String)
	@project_root_dir + '/' + @pattern[:prefix]+unit_base_name.to_s+@pattern[:suffix]
end #path
def parse_pathname_regexp
	Absolute_directory_regexp.capture(:project_root_directory)*@pattern[:prefix]+/[[:word:]]+/.capture(:unit_base_name)+@pattern[:suffix]
end #parse_pathname_regexp
def pathname_glob(unit_base_name = '*', project_root_directory = @project_root_dir)
	project_root_directory+@pattern[:prefix]+unit_base_name.to_s+@pattern[:suffix]
end #pathname_glob
def relative_path?(unit_base_name)
	Pathname.new(path?(unit_base_name)).relative_path_from(Pathname.new(Dir.pwd))
end #relative_path
module ReferenceObjects
Library = FilePattern.new_from_path(__FILE__)
# TODO rename Executable to Program_name (case?)
Executable = FilePattern.new_from_path($0)
end # ReferenceObjects
include ReferenceObjects
#require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
# conditions that are always true (at least atomically)
def assert_invariant
#	fail "end of assert_invariant "
end # class_assert_invariant
# conditions true while class is being defined
def assert_pre_conditions
#	assert_respond_to(FilePattern, :project_root_dir?)
#	assert_module_included(self, FilePattern::Assertions)
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions
	path = File.expand_path($0)
#	refute_nil(path)
#	refute_empty(path)
#	assert(File.exist?(path))
#	refute_empty(FilePattern.class_variables)
#	assert_includes(FilePattern.class_variables, :@@project_root_dir)
#	assert_pathname_exists(FilePattern.class_variable_get(:@@project_root_dir))
end #class_assert_post_conditions
def assert_pattern_array(array, array_message = '')
	message = "\ndefault FilePattern.project_root_dir?=#{FilePattern.project_root_dir?.inspect}"
	successes = array.map do |p|
		p[:example_file].match(p[:prefix])
		p[:example_file].match(p[:suffix])
	end #map
#	assert(successes.all?, successes.inspect+"\n"+array.inspect)
#	refute_empty(array, array_message)
end #assert_pattern_array
end #ClassMethods
# conditions that are always true (at least atomically)
def assert_invariant
	fail "end of assert_invariant "
end #assert_invariant
# assertions true after instance is initialized
def assert_pre_conditions(message = '')
#	refute_nil(@path, 'Path is nil'+ self.inspect)
#	refute_empty(@path)
	message+="\n @pattern = #{@pattern.inspect}\n @pattern = #{@pattern.inspect}"
#	refute_equal('{}',@pattern.inspect, message)
#	refute_nil(@pattern, message)
#	assert_instance_of(Hash, @pattern, message)
#	assert(!@pattern.keys.empty?, message)
#	refute_empty(@pattern.values, message)
#	assert_includes(@pattern.keys, :suffix, inspect)
#	assert_equal(@path[-@pattern[:suffix].size, @pattern[:suffix].size], @pattern[:suffix])
#	fail message+"end of assert_pre_conditions "
end #assert_pre_conditions
# assertions true after any instance operations
def assert_post_conditions(message = 'self = '+self.inspect)
#	refute_empty(@project_root_dir, message)
#	assert_pathname_exists(@project_root_dir)
#	assert(File.exist?(@path))
#	find_all_from_path = FilePattern.find_all_from_path(@path)
#	assert_equal(1, find_all_from_path.size, find_all_from_path)
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
module Examples
Path4 = 'test/unit/minimal4_assertions_test.rb'
DCT_filename = 'script/dct.rb'
#DCT=FilePattern.new_from_path(FilePattern.path2model_name?(DCT_filename), FilePattern.project_root_dir?(DCT_filename))
SELF_Model = __FILE__
SELF_Test = $0
#SELF=FilePattern.new_from_path(FilePattern.path2model_name?(SELF_Model), FilePattern.project_root_dir?(SELF_Model))
Data_source_example = 'test/data_sources/tax_form/2012/examples_and_templates/US_1040/US_1040_example_sysout.txt'
end #Examples
end #FilePattern
