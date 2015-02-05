###########################################################################
#    Copyright (C) 2012-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit'
TestCase=Test::Unit::TestCase
require_relative '../../test/assertions/ruby_assertions.rb'
#AssertionFailedError=Test::Unit::AssertionFailedError
AssertionFailedError = RuntimeError
#AssertionFailedError = MiniTest::Assertion
#assert_global_name(:AssertionFailedError)