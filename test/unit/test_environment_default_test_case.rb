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
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/test_introspection.rb'
require_relative '../../app/models/test_environment.rb'

include TestIntrospection
TE=TestEnvironment.new
DefaultTests=eval(TE.default_tests_module_name?)
TestCase=eval(TE.test_case_class_name?)
#assert_equal(:DefaultTests0, TE.test_case_class_name?)
#assert_kind_of(DefaultTests0, TestCase)
AssertionFailedError=MiniTest::Assertion
#require_relative '../../test/unit/default_test_case.rb'
