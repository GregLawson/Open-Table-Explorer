###########################################################################
#    Copyright (C) 2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
module Assertions
require 'test/unit'
include Test::Unit::Assertions
# Assertions (validations)
module ClassMethods
def assert_invariant

end # class_assert_invariant
def assert_pre_conditions
	assert_invariant
end #class_assert_pre_conditions

def assert_post_conditions
	assert_invariant
	self.example_constants_by_class(self).each do |c|
		c.assert_pre_conditions
	end #each
end #class_assert_post_conditions
def value_of_example?(name)
	const_get(name.to_s)
end #value_of_example
def example_constants_by_class(klass)
	constants.select do |c|
		value_of_example?(c).instance_of?(klass)
	end #select
end #example_constants_by_class
end #ClassMethods
def assert_pre_conditions
	self.class.assert_pre_conditions
	assert_invariant
end #assert_pre_conditions
def assert_invariant
	self.class.assert_invariant

end #def assert_invariant

def assert_post_conditions
	self.class.assert_post_conditions
	assert_invariant
end #assert_post_conditions
end #Assertions

module TestCaseHelpers
end #TestCases
