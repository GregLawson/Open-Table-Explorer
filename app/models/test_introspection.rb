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
module Constants
	# ordered from common to rare, ambiguous to specific
	Suffixes=[
	{:suffix =>'.rb', :name => :model, :sub_directory => 'app/models/'}, 
	{:suffix =>'_test.rb', :name => :test, :sub_directory => 'test/unit/'}, 
	{:suffix =>'_assertions.rb', :name => :assertions, :sub_directory => 'test/assertions/'}, 
	{:suffix =>'_assertions_test.rb', :name => :assertions_test, :sub_directory => 'test/unit/'}
	]
end  #Constants
include Constants
def naming_convention_extension(s, extension)
	extension==File.extname(s[:suffix])
end #naming_convention_match
def naming_convention_basename(s, basename, extension)
	expected_baseline=File.basename(s[:suffix], extension)
	basename[-expected_baseline.size,expected_baseline.size]==expected_baseline
end #naming_convention_match
def path2model_name?(path=File.expand_path($0))
	extension=File.extname(path)
	basename=File.basename(path, extension)
	matches=Suffixes.reverse.map do |s| #reversed from rare to common
		if naming_convention_extension(s, extension) && naming_convention_basename(s, basename, extension) then
			name_length=basename.size+extension.size-s[:suffix].size
			basename[0,name_length].classify.to_sym
		else
			nil
		end #if	
	end #map
	matches.compact.last
end #path2model_name
def project_root_dir?(path=File.expand_path($0))
	script_directory_pathname=File.dirname(path)+'/'
	script_directory_name=File.basename(script_directory_pathname)
	case script_directory_name
	when 'unit' then
		File.expand_path(script_directory_pathname+'../../')+'/'
	when 'script' then
		File.dirname(script_directory_pathname)
	when 'models'
		File.expand_path(script_directory_pathname+'../../')+'/'
	else
		fail "can't find test directory"
	end #case
end #project_root_dir
def lookup(name, param_name)
	ret=Suffixes.find do |s|
		s[:name]==name
	end #find
	ret[param_name]
end #lookup
def model_basename?(test_file_path=File.expand_path($0))
	File.basename(test_file_path, '.rb')[0..-6]
end #model_basename
def class_name?(model_basename=model_basename?)
	model_basename.classify
end #class_name
def name_of_test?(model_basename=model_basename?)
	model_basename.classify.to_s+'Test'
end #name_of_test
module Assertions
def assert_naming_convention_match(s, basename, extension)
	assert_equal(extension, File.extname(s[:suffix]))
	assert(naming_convention_extension(s, extension))
	assert(naming_convention_basename(s, basename, extension))
end #naming_convention_match
def assert_pre_conditions
	assert_module_included(self, TestIntrospection::Assertions)
end #assert_pre_conditions
end #Assertions
include Assertions
#TestIntrospection.assert_pre_conditions
#assert_include(TestIntrospection.included_modules, :Assertions)
#assert_pre_conditions
end #TestIntrospection
