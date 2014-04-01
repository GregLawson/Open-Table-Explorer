###########################################################################
#    Copyright (C) 2012-2014 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require "minitest/autorun"
require 'active_support/all'
# gem install mintest
module Test
module Unit
module Assertions
include Minitest::Assertions
end # Assertions
end # Unit
end # Test
require_relative '../../app/models/default_test_case.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/related_file.rb'
TE=RelatedFile.new
DefaultTests=eval(TE.default_tests_module_name?)
TestCase=eval(TE.test_case_class_name?)
# AssertionFailedError=Test::Unit::AssertionFailedError
