###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_default_test_case.rb'
class TestEnvironmentDefaultTestCaseTest < TestCase
#include DefaultTests
def test_ruby_assertions
end # ruby_assertions
def regexp_error(regexp_string)
	raise "Argument to regexp_error is expected to be a String; but regexp_string=#{regexp_string.inspect}" unless regexp_string.instance_of?(String)
	Regexp.new(regexp_string) # test
	return nil # if no RegexpError
rescue RegexpError => exception
	return exception
end #regexp_error
def assert_requires(required_path)
	required_unit = Unit.new_from_path(required_path)
end # requires
def test_requires_minitest
	assert_requires('../../app/models/test_environment_minitest.rb')
end # requires_minitest
def test_requires_default_test_case
	assert_requires('../../app/models/default_test_case.rb')
end # requires_default_test_case
def test_RegexpError
	regexp_string = ')'
	Regexp.new(regexp_string) # test
rescue RegexpError => exception
	assert_instance_of(RegexpError, exception)
	assert_includes(exception.class.ancestors, Exception)
end # AssertionFailedError
def test_AssertionFailedError
	fail # test
rescue Exception => exception
	assert_kind_of(Exception, exception)
	assert_includes(exception.class.ancestors, Exception)
	assert_instance_of(AssertionFailedError, exception)
end # AssertionFailedError
end # TestEnvironmentTest
