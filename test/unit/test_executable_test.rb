###########################################################################
#    Copyright (C) 2011-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require 'active_support' # for singularize and pluralize
require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/test_executable.rb'
# executed in alphabetical order. Longer names sort later.
class TestTestExecutable < TestCase
include TestExecutable::Examples
include Repository::Constants
def test_virtus_initialize
	assert_equal('code_base', Odd_plural_executable.singular_table)
	assert_equal('code_bases', Odd_plural_executable.plural_table)
	assert_equal(nil, Odd_plural_executable.test)
	assert_equal(:code_base, Odd_plural_executable.unit?.model_class_name, Odd_plural_executable.inspect)
	assert_equal(:code_base, Odd_plural_executable.unit?.model_class_name.to_s.underscore.to_sym, Odd_plural_executable.inspect)

	assert_equal(:code_base, Odd_plural_executable.unit?.model_basename, Odd_plural_executable.inspect)
	assert_equal(:unit, Odd_plural_executable.test_type)
	assert_equal(:unit, Default_executable.test_type)
end # virtus_initialize
def test_TestExecutable_initialize
	testRun = TestExecutable.new
	assert_equal(:unit, testRun.test_type, testRun.inspect)
#	TestExecutable.column_names.each do |n|
#		assert_instance_of(String,n)
#	end #each
	# prove equivalence of attribute access
	assert_respond_to(testRun, 'singular_table')
	testRun.singular_table='method'
	assert_equal('method', testRun.singular_table)
	assert_equal('method', testRun.attributes[:singular_table])
	assert_nil(testRun.attributes['singular_table'])
	
	testRun[:singular_table]='sym_hash'
	assert_equal('sym_hash', testRun.singular_table)
	assert_equal('sym_hash', testRun[:singular_table])
	
	testRun['singular_table']='string_hash'
	assert_equal('string_hash', testRun.singular_table)
	assert_equal('string_hash', testRun[:singular_table])
	
#	Singular_executable.assert_logical_primary_key_defined
#	Stream_pattern_executable.assert_logical_primary_key_defined()
#	Unit_executable.assert_logical_primary_key_defined()
	assert_equal(:unit, testRun.test_type, testRun.inspect)
end #initialize
def test_new_from_path
	executable_file = $0
	unit = Unit.new_from_path(executable_file)
	repository = Repository::This_code_repository
	new_executable = TestExecutable.new(executable_file: executable_file, 
								unit: unit, repository: repository)
	new_from_path_executable = TestExecutable.new_from_path($0)
	assert_instance_of(TestExecutable, new_executable)
	assert_equal(:unit, Unit_executable.test_type)
	assert_equal(:unit, new_executable.test_type)
	assert_equal(:unit, new_from_path_executable.test_type)
	assert_equal(:unit, Default_executable.test_type)
end # new_from_path
def test_log_path?
	unit = Unit.new_from_path($0)
	refute_nil(unit)
	assert_equal('log/unit/1.9/1.9.3p194/silence/test_executable.log', Default_executable.log_path?)
end # log_path?
def test_ruby_test_string
	executable_file = $PROGRAM_NAME
	ruby_test_string = Default_executable.ruby_test_string
	assert_match(executable_file, ruby_test_string)
end # ruby_test_string
def test_write_commit_message
end # write_commit_message
def test_test_file?
	assert_equal('test/unit/code_base_test.rb',Odd_plural_executable.test_file?)
end #test_file?
def test_Examples
	assert_equal(:unit, Unit_executable.test_type)
	assert_equal(:unit, Plural_executable.test_type)
	assert_equal(:unit, Singular_executable.test_type)
	assert_equal(:unit, Odd_plural_executable.test_type)
	assert_equal(:unit, Default_executable.test_type)
end # Examples
end # TestExecutable
