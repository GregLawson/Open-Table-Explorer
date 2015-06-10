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
	assert_equal(:unit, Odd_plural_executable.test_type)
	assert_equal('code_base', Odd_plural_executable.singular_table)
	assert_equal('code_bases', Odd_plural_executable.plural_table)
	assert_equal(nil, Odd_plural_executable.test)
end # virtus_initialize
def test_TestExecutable_initialize
	testRun=TestExecutable.new
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
end #initialize
def test_new_from_pathname
	unit = Unit.new_from_path?(executable_file_file)
	new_executable_file = TestExecutable.new(executable_file: executable_file, unit: unit)
end # new_from_pathname
def test_log_path?
	executable_file = $PROGRAM_NAME
	assert_equal('log/unit/1.9/1.9.3p194/quiet/repository.log', This_code_repository.log_path?(executable_file))
#	assert_equal('log/unit/1.9/1.9.3p194/quiet/repository.log', This_code_repository.log_path?)
end # log_path?
def test_ruby_test_string
	executable_file = $PROGRAM_NAME
	ruby_test_string = This_code_repository.ruby_test_string(executable_file)
	assert_match(executable_file, ruby_test_string)
end # ruby_test_string
def test_TestExecutable_initialize
end #initialize
def test_log_file
	test_virtus_initialize
	assert_equal(:unit, Odd_plural_executable.test_type)
	assert_equal('code_base', Odd_plural_executable.singular_table)
	assert_equal(:code_base, Odd_plural_executable.unit?.model_class_name, Odd_plural_executable.inspect)
	assert_equal(:code_base, Odd_plural_executable.unit?.model_class_name.to_s.underscore.to_sym, Odd_plural_executable.inspect)

	assert_equal(:code_base, Odd_plural_executable.unit?.model_basename, Odd_plural_executable.inspect)
	assert_equal(File.expand_path('log/library/code_base.log'), Odd_plural_executable.log_file, Odd_plural_executable.inspect)
end #log_file
def test_test_file?
	assert_equal('test/unit/code_base_test.rb',Odd_plural_executable.test_file?)
end #test_file?
def test_unit_names?
	assert_equal(['repository'], Minimal_repository.unit_names?([$0]))	
end #unit_names?
end # TestExecutable
