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
require_relative '../../app/models/unit.rb'
TE=Unit.new
BaseTestCase = MiniTest::Unit::TestCase 
TestCase = BaseTestCase
AssertionsModule = MiniTest::Assertions
AssertionFailedError = RuntimeError
#AssertionFailedError=Test::Unit::AssertionFailedError
#AssertionFailedError = MiniTest::Assertion
#assert_global_name(:AssertionFailedError)AssertionsModule.include(RubyAssertions)AssertionsModule.extend(RubyAssertions)