###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class NamingConvention < Hash
module Constants
	# ordered from ambiguous to specific, common to rare
Patterns=[
	{:suffix =>'.rb', :name => :model, :sub_directory => 'app/models/'}, 
	{:suffix =>'.rb', :name => :script, :sub_directory => 'script/'}, 
	{:suffix =>'_test.rb', :name => :test, :sub_directory => 'test/unit/'}, 
	{:suffix =>'_assertions.rb', :name => :assertions, :sub_directory => 'test/assertions/'}, 
	{:suffix =>'_assertions_test.rb', :name => :assertions_test, :sub_directory => 'test/unit/'}
	]
All=Patterns.reverse.map {|s| NamingConvention.new(s)}	
end  #Constants
include Constants
module ClassMethods
def all
	Constants::All
end #all
def path2model_name?(path=$0)
	raise "path=#{path.inspect} must be a string" if !path.instance_of?(String)
	path=File.expand_path(path)
	extension=File.extname(path)
	basename=File.basename(path)
	matches=all.map do |s| #reversed from rare to common
		if s.suffix_match(path) && s.sub_directory_match(path) then
			name_length=basename.size-s[:suffix].size
			basename[0,name_length].classify.to_sym
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
	when 'script' then
		File.dirname(script_directory_pathname)+'/'
	when 'models'
		File.expand_path(script_directory_pathname+'../../')+'/'
	else
		fail "can't find test directory"
	end #case
	raise "ret=#{ret} does not end in a slash\npath=#{path}" if ret[-1,1]!= '/'
	return ret
end #project_root_dir
def find_by_name(name)
	ret=Constants::Patterns.find do |s|
		s[:name]==name
	end #find
end #find_by_name
def pathnames?(model_basename)
#	[assertions_test_pathname?, assertions_pathname?, model_test_pathname?, model_pathname?]
	raise "project_root_dir" if @@project_root_dir.nil?
	raise "@model_basename" if model_basename.nil?
	pathnames=Patterns.map do |p|
		p.path?(model_basename)
	end #
end #pathnames
#NamingConvention.assert_pre_conditions
#assert_include(NamingConvention.included_modules, :Assertions)
#assert_pre_conditions
end #ClassMethods
extend ClassMethods
@@project_root_dir=self.project_root_dir?
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
	raise "" if !@@project_root_dir.instance_of?(String)
	raise self.inspect if !self.instance_of?(NamingConvention)
	raise self.inspect if !self[:sub_directory].instance_of?(String)
	raise "" if !model_basename.instance_of?(String)
	raise "" if !self[:suffix].instance_of?(String)
	@@project_root_dir+self[:sub_directory]+model_basename.to_s+self[:suffix]
end #path
module Assertions
require_relative '../../test/assertions/ruby_assertions.rb'
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
# conditions that are always true (at least atomically)
def assert_invariant
#	fail "end of assert_invariant "
end # class_assert_invariant
# conditions true while class is being defined
def assert_pre_conditions
	assert_respond_to(NamingConvention, :project_root_dir?)
	assert_module_included(self, NamingConvention::Assertions)
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions
	assert_equal(TE, NamingConvention::Examples::SELF)
end #class_assert_post_conditions
end #ClassMethods
# conditions that are always true (at least atomically)
def assert_invariant
	fail "end of assert_invariant "
end #assert_invariant
# conditions true while class is being defined
# assertions true after class (and nested module Examples) is defined
def assert_pre_conditions
	assert(!keys.empty?, "self=#{self.inspect}")
	assert_not_empty(values, "")
	fail "end of assert_pre_conditions "
end #class_assert_pre_conditions
# assertions true after class (and nested module Examples) is defined
def assert_post_conditions
	message+="\ndefault NamingConvention.project_root_dir?=#{NamingConvention.project_root_dir?.inspect}"
	assert_not_empty(@project_root_dir, message)
end #assert_post_conditions


end #Assertions
include Assertions
extend Assertions::ClassMethods
end #NamingConvention