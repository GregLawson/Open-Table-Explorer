###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit'
require 'pathname'
require_relative 'regexp.rb'
require 'active_support/all'
class FilePattern <  ActiveSupport::HashWithIndifferentAccess
module Constants
# ordered from ambiguous to specific, common to rare
Patterns=[
	{:suffix =>'.rb', :name => :model, :prefix => 'app/models/', :example_file => __FILE__},
	{:suffix =>'_test.rb', :name => :test, :prefix => 'test/unit/', :example_file => $0},
	{:suffix =>'.rb', :name => :script, :prefix => 'script/', :example_file => 'script/work_flow.rb'},
	{:suffix =>'_test.rb', :name => :integration_test, :prefix => 'test/integration/', :example_file => 'test/integration/repository_test.rb'}, 
	{:suffix =>'_test.rb', :name => :long_test, :prefix => 'test/long_test/', :example_file => 'test/long_test/repository_test.rb'}, 
	{:suffix =>'_assertions.rb', :name => :assertions, :prefix => 'test/assertions/', :example_file => 'test/assertions/repository_assertions.rb'}, 
	{:suffix =>'_assertions_test.rb', :name => :assertions_test, :prefix => 'test/unit/', :example_file => 'test/unit/repository_assertions_test.rb'},
	{:suffix =>'', :name => :data_sources_dir, :prefix => 'test/data_sources/', :example_file => 'test/data_sources/tax_form/CA540'}
	]
All=Patterns.map {|s| FilePattern.new(s)}	
include Regexp::Constants
Directory_delimiter=/\//
Basename_character_regexp=/[[:word:]\. -]/
Basename_regexp=Basename_character_regexp*Many
Pathname_character_regexp=/[[:word:]\. \/-]/
Relative_pathname_regexp=Start_string*Pathname_character_regexp*Many*End_string
Absolute_pathname_regexp=Start_string*Directory_delimiter*Pathname_character_regexp*Many*End_string
Relative_directory_regexp=Start_string*Pathname_character_regexp*Many*End_string
Absolute_directory_regexp=Start_string*Directory_delimiter*Pathname_character_regexp*Many*End_string
end  #Constants
include Constants
module ClassMethods
def all
	Constants::All
end #all
def path2model_name?(path=$0)
	raise "path=#{path.inspect} must be a string" if !path.instance_of?(String)
	path=File.expand_path(path)
	basename=File.basename(path)
	matches=all.map do |s| 
		if s.suffix_match(path) && s.prefix_match(path) then
			name_length=basename.size-s[:suffix].size
			basename[0,name_length].camelize.to_sym
		else
			nil
		end #if	
	end #map
	matches.compact.last
end #path2model_name
def project_root_dir?(path=$0)
	path=File.expand_path(path)
	roots=FilePattern::All.map do |p|
		matchData=Regexp.new(p[:prefix]).match(path)
		if matchData.nil? then
			nil
		else
			test_root=matchData.pre_match
		end #if
	end #map
	message='path='+path.inspect
	message+="\nroots="+roots.inspect
	raise message if roots.uniq.compact.size!=1
	roots.compact[0]
end #project_root_dir
def find_by_name(name)
	Constants::All.find do |s|
		s[:name]==name
	end #find
end #find_by_name
def find_from_path(path)
	Constants::All.find do |p|
		p.prefix_match(path) && p.suffix_match(path)
	end #find
end #find_from_path
def pathnames?(model_basename)
#	raise "project_root_dir" if FilePattern.class_variable_get(:@@project_root_dir).nil?
	raise "model_basename" if model_basename.nil?
	FilePattern::Constants::All.map do |p|
		p.path?(model_basename)
	end #
end #pathnames
#FilePattern.assert_pre_conditions
#assert_include(FilePattern.included_modules, :Assertions)
#assert_pre_conditions
end #ClassMethods
extend ClassMethods
module Constants
Project_root_directory=FilePattern.project_root_dir?($0)
end #Constants
def initialize(hash)
	@pattern=hash
	super(hash)
end #initialize
#def inspect
#	message="FilePattern<instance_variables=#{instance_variables.inspect}, self=#{self.inspect}>"
#end #inspect
def suffix_match(path)
	path[-self[:suffix].size, self[:suffix].size] == self[:suffix]
end #suffix_match
def prefix_match(path)
	path=File.expand_path(path)
	matchData=Regexp.new(self[:prefix]).match(path)
#	prefix=File.dirname(path)
#	expected_prefix=self[:prefix][0..-2] # drops trailing /
#	prefix[-expected_prefix.size,expected_prefix.size]==expected_prefix
end #prefix_match
def path?(model_basename)
#	raise "" if !@@project_root_dir.instance_of?(String)
	raise self.inspect if !self.instance_of?(FilePattern)
	raise self.inspect if !self[:prefix].instance_of?(String)
	raise "model_basename-#{model_basename.inspect}" if !model_basename.instance_of?(String)
	raise "" if !self[:suffix].instance_of?(String)
	self[:prefix]+model_basename.to_s+self[:suffix]
end #path
def parse_pathname_regexp
	Absolute_directory_regexp.capture(:project_root_directory)*self[:prefix]+/[[:word:]]+/.capture(:model_basename)+self[:suffix]
end #parse_pathname_regexp
def pathname_glob(model_basename='*')
	Project_root_directory+self[:prefix]+model_basename+self[:suffix]
end #pathname_glob
def relative_path?(model_basename)
	Pathname.new(path?(model_basename)).relative_path_from(Pathname.new(Dir.pwd))
end #relative_path
include Constants
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
	path=File.expand_path($0)
	assert_not_nil(path)
	assert_not_empty(path)
	assert(File.exists?(path))
#	assert_not_empty(FilePattern.class_variables)
#	assert_include(FilePattern.class_variables, :@@project_root_dir)
#	assert_pathname_exists(FilePattern.class_variable_get(:@@project_root_dir))
end #class_assert_post_conditions
def assert_pattern_array(array, array_message='')
	successes=array.map do |p|
		p[:example_file].match(p[:prefix])
	end #map
	assert(successes.all?, successes.inspect+"\n"+array.inspect)
	assert_not_empty(array, array_message)
	array.each_with_index do |n, i| 
		message=array_message+" \n n=#{n.inspect}"
		n.assert_pre_conditions(message)
	end #map
end #assert_pattern_array
end #ClassMethods
# conditions that are always true (at least atomically)
def assert_invariant
	fail "end of assert_invariant "
end #assert_invariant
# assertions true after instance is initialized
def assert_pre_conditions(message='')
	assert_kind_of(FilePattern, self)
	message+="\n self=#{self.inspect}\n self=#{self.inspect}"
	assert_not_equal('{}',self.inspect, message)
	assert_not_nil(self, message)
	assert_instance_of(FilePattern, self, message)
	assert(!self.keys.empty?, message)
	assert_not_empty(self.values, message)
	assert_include(self.keys, :suffix.to_s, inspect)
#	fail message+"end of assert_pre_conditions "
end #assert_pre_conditions
# assertions true after any instance operations
def assert_post_conditions
	message+="\ndefault FilePattern.project_root_dir?=#{FilePattern.project_root_dir?.inspect}"
	assert_not_empty(@project_root_dir, message)
end #assert_post_conditions
def assert_naming_convention_match(path)
	path=File.expand_path(path)
	assert_equal(path[-self[:suffix].size, self[:suffix].size], self[:suffix], caller_lines)
	assert(self.suffix_match(path), self.inspect+caller_lines)
	assert(self.prefix_match(path), self.inspect+caller_lines)
	message="self=#{self.inspect}, path=#{path.inspect}"
end #naming_convention_match
end #Assertions
include Assertions
extend Assertions::ClassMethods
module Examples
DCT_filename='script/dct.rb'
#DCT=FilePattern.new(FilePattern.path2model_name?(DCT_filename), FilePattern.project_root_dir?(DCT_filename))
SELF_Model=__FILE__
SELF_Test=$0
#SELF=FilePattern.new(FilePattern.path2model_name?(SELF_Model), FilePattern.project_root_dir?(SELF_Model))
Data_source_example='test/data_sources/tax_form/examples_and_templates/US_1040/US_1040_example_sysout.txt'
end #Examples
end #FilePattern
