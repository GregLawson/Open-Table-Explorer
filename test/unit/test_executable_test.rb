###########################################################################
#    Copyright (C) 2011-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
#require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/test_executable.rb'
class FileArgumentTest < TestCase
include FileArgument::Examples
end # FileArgument

class TestExecutableTest < TestCase
include TestExecutable::Examples
include Repository::Constants
def test_TestExecutable_initialize
	assert_equal(nil, Default_executable.test)
	assert_equal(:unit, Default_executable.test_type, Default_executable.inspect)
#	TestExecutable.column_names.each do |n|
#		assert_instance_of(String,n)
#	end #each
	
#	Singular_executable.assert_logical_primary_key_defined
#	Stream_pattern_executable.assert_logical_primary_key_defined()
#	Unit_executable.assert_logical_primary_key_defined()
	assert_equal(:unit, Default_executable.test_type, Default_executable.inspect)
	assert_equal(:unit, Default_executable.test_type)
end #initialize
def test_new_from_path
	executable_file = $0
	unit = Unit.new_from_path(executable_file)
	repository = Repository::This_code_repository
	new_executable = TestExecutable.new(executable_file: executable_file, 
								unit: unit, repository: repository)
	new_from_path_executable = TestExecutable.new_from_path($0)
	assert_instance_of(TestExecutable, new_executable)
end # new_from_path
def test_log_path?
	unit = Unit.new_from_path($0)
	refute_nil(unit)
	assert_equal('log/unit/2.2/2.2.3p173/silence/test_executable.log', Default_executable.log_path?)
end # log_path?
def test_ruby_test_string
	executable_file = $PROGRAM_NAME
	ruby_test_string = Default_executable.ruby_test_string
	assert_match(executable_file, ruby_test_string)
end # ruby_test_string
def test_write_commit_message
end # write_commit_message
def test_Examples
	assert_equal(:unit, Default_executable.test_type)
end # Examples
end # TestExecutable
