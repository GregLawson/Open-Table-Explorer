###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
clclass GenericTableExamplesTest < TestCase
extend DefaultAssertions::ClassMethods
def test_example_constants_by_class
	assert_include(Minimal.constants, :Constant)
	assert_equal(Minimal::Constant, Minimal.value_of_example?(:Constant))
	assert_equal([:Constant], Minimal.example_constant_names_by_class(Fixnum))
	assert_equal([:Constant], Minimal.example_constant_names_by_class(Fixnum, /on/))
end #example_constant_names_by_class
end #MinimalTest