###########################################################################
#    Copyright (C) 2012-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# gem install mintest
require "minitest/autorun"
require 'active_support/all'
require_relative '../../test/assertions/ruby_assertions.rb'
#require_relative '../../app/models/default_test_case.rb'
require_relative '../../app/models/unit.rb'
TE=Unit.new
#DefaultTests = eval(TE.default_tests_module_name?)
#TestCase=eval(TE.test_case_class_name?)
TestCase = MiniTest::Unit::TestCase
#AssertionFailedError=Test::Unit::AssertionFailedError
AssertionFailedError = RuntimeError
#AssertionFailedError = MiniTest::Assertion
#assert_global_name(:AssertionFailedError)