###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit'
include Test::Unit::Assertions
#TestCase=Test::Unit::TestCase #computed below
require_relative 'default_test_case.rb'
require_relative '../../app/models/test_environment.rb'
TE=TestEnvironment.new
DefaultTests=eval(TE.default_tests_module_name?)
TestCase=eval(TE.test_case_class_name?)
AssertionFailedError=MiniTest::Assertion
