###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../unit/test_environment'
require_relative '../unit/test_environment_default_test_case.rb'
class TestEnvironmentTest < TestCase
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

def test_RegexpError
	regexp_string = ')'
	Regexp.new(regexp_string) # test
rescue RegexpError => exception
	assert_instance_of(RegexpError, exception)
	assert_include(exception.class.ancestors, Exception)
end # AssertionFailedError
def test_AssertionFailedError
	fail # test
rescue Exception => exception
	assert_kind_of(Exception, exception)
	assert_include(exception.class.ancestors, Exception)
	assert_instance_of(AssertionFailedError, exception)
end # AssertionFailedError
end #TestEnvironmentTest
