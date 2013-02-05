###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions/minimal_assertions.rb'
require_relative '../../test/unit/default_assertions_tests.rb'
class MinimalTest < TestCase
include DefaultAssertions
extend DefaultAssertions::ClassMethods
include DefaultAssertionTests
def test_example_constants_by_class
	assert_include(Minimal.constants, :Constant)
	assert_equal(Minimal::Constant, Minimal.value_of_example?(:Constant))
	assert_equal([:Constant], Minimal.example_constant_names_by_class(Fixnum))
	assert_equal([:Constant], Minimal.example_constant_names_by_class(Fixnum, /on/))
end #example_constant_names_by_class
end #MinimalTest
