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
	{:suffix =>'.rb', :name => :model, :sub_directory => 'app/models/'}, 
	{:suffix =>'_test.rb', :name => :test, :sub_directory => 'test/unit/'}, 
	{:suffix =>'.rb', :name => :script, :sub_directory => 'script/'}, 
	{:suffix =>'_test.rb', :name => :integration_test, :sub_directory => 'test/integration/'}, 
	{:suffix =>'_test.rb', :name => :long_test, :sub_directory => 'test/long_test/'}, 
	{:suffix =>'_assertions.rb', :name => :assertions, :sub_directory => 'test/assertions/'}, 
	{:suffix =>'_assertions_test.rb', :name => :assertions_test, :sub_directory => 'test/unit/'},
	{:suffix =>'*', :name => :data_source_dir, :sub_directory => 'test/dsta_sources/'}
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
		if s.suffix_match(path) && s.sub_directory_match(path) then
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
	script_directory_pathname=File.dirname(path)+'/'
	script_directory_name=File.basename(script_directory_pathname)
	ret=case script_directory_name
	when 'unit' then
		File.expand_path(script_directory_pathname+'../../')+'/'
	when 'assertions' then
		File.expand_path(script_directory_pathname+'../../')+'/'
	when 'long_test' then
		File.expand_path(script_directory_pathname+'../../')+'/'
	when 'integration' then
		File.expand_path(script_directory_pathname+'../../')+'/'
	when 'script' then
		File.dirname(script_directory_pathname)+'/'
	when 'models'
		File.expand_path(script_directory_pathname+'../../')+'/'
	else
		warn "can't find test directory. path=#{path.inspect}\n  script_directory_pathname=#{script_directory_pathname.inspect}\n script_directory_name=#{script_directory_name.inspect}"
		script_directory_name+'/'
	end #case
	raise "ret=#{ret} does not end in a slash\npath=#{path}" if ret[-1,1]!= '/'
	return ret
end #project_root_dir
def find_by_name(name)
	Constants::All.find do |s|
		s[:name]==name
	end #find
end #find_by_name
def find_from_path(path)
	Constants::All.find do |p|
		p.sub_directory_match(path) && p.suffix_match(path)
	end #find
end #pattern_from_path
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
#	message="FilePattern<instance_variables=#{instance_variables.inspect}, @self=#{self.inspect}>"
#end #inspect
def suffix_match(path)
	path[-self[:suffix].size, self[:suffix].size] == self[:suffix]
end #suffix_match
def sub_directory_match(path)
	path=File.expand_path(path)
	sub_directory=File.dirname(path)
	expected_sub_directory=self[:sub_directory][0..-2] # drops trailing /
	sub_directory[-expected_sub_directory.size,expected_sub_directory.size]==expected_sub_directory
end #sub_directory_match
def path?(model_basename)
#	raise "" if !@@project_root_dir.instance_of?(String)
	raise self.inspect if !self.instance_of?(FilePattern)
	raise self.inspect if !self[:sub_directory].instance_of?(String)
	raise "model_basename-#{model_basename.inspect}" if !model_basename.instance_of?(String)
	raise "" if !self[:suffix].instance_of?(String)
	self[:sub_directory]+model_basename.to_s+self[:suffix]
end #path
def parse_pathname_regexp
	Absolute_directory_regexp.capture(:project_root_directory)*self[:sub_directory]+/[[:word:]]+/.capture(:model_basename)+self[:suffix]
end #parse_pathname_regexp
def pathname_glob(model_basename='*')
	Project_root_directory+self[:sub_directory]+model_basename+self[:suffix]
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
	assert_not_empty(array, array_message)
	array.each_with_index do |n, i| 
		message=array_message+" \n n=#{n.inspect}"
		n.assert_pre_conditions(message)
	end #map
end #assert_pattern_srray
end #ClassMethods
# conditions that are always true (at least atomically)
def assert_invariant
	fail "end of assert_invariant "
end #assert_invariant
# conditions true while class is being defined
# assertions true after class (and nested module Examples) is defined
def assert_pre_conditions(message='')
	message+="\n self=#{self.inspect}\n self=#{self.inspect}"
	assert_not_equal('{}',self.inspect, message)
	assert_not_nil(self, message)
	assert_instance_of(FilePattern, self, message)
	assert(!self.keys.empty?, message)
	assert_not_empty(self.values, message)
#	fail message+"end of assert_pre_conditions "
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions
	message+="\ndefault FilePattern.project_root_dir?=#{FilePattern.project_root_dir?.inspect}"
	assert_not_empty(@project_root_dir, message)
end #assert_post_conditions
def assert_naming_convention_match(path)
	path=File.expand_path(path)
	assert_equal(path[-self[:suffix].size, self[:suffix].size], self[:suffix], caller_lines)
	sub_directory=File.dirname(path)
	expected_sub_directory=self[:sub_directory][0..-2] # drops trailing /
	message="expected_sub_directory=#{expected_sub_directory}\nsub_directory=#{sub_directory}"
	assert_not_nil(sub_directory[-expected_sub_directory.size,expected_sub_directory.size], message+caller_lines)
	assert_equal(sub_directory[-expected_sub_directory.size,expected_sub_directory.size], expected_sub_directory, message+caller_lines)
	message="self=#{self}\nsub_directory=#{sub_directory}\nexpected_sub_directory=#{expected_sub_directory}"
	message+="\n self.sub_directory_match(path)=#{self.sub_directory_match(path)}"
	assert(self.sub_directory_match(path), message+caller_lines)
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
end #Examples
end #FilePattern
