###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_minitest.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require "minitest/autorun"
require 'active_support/all'
require_relative '../../app/models/default_test_case.rb'
#require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/unit.rb'
TE=Unit.new
DefaultTests=eval(TE.default_tests_module_name?)
TestCase=eval(TE.test_case_class_name?)
# AssertionFailedError=Test::Unit::AssertionFailedError
TestCase = MiniTest::Unit::TestCase
class MinitestTest < TestCase
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
def test_ruby_assertions
	refute_empty([1])
end # ruby_assertions
end # MinitestTest
