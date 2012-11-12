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

end # assert_invariant
def assert_pre_conditions
	assert_invariant
end #assert_pre_conditions

def assert_post_conditions
	assert_invariant
	constants_by_class(self).each do |c|
		c.assert_pre_conditions
	end #each
end #assert_post_conditions
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
module TestCases
def self.value_of?(name)
	RegexpParse::TestCases.const_get(name.to_s)
end #value_of
def self.constants_by_class(klass)
	RegexpParse::TestCases.constants.select do |c|
		value_of?(c).instance_of?(klass)
	end #select
end #constants_by_class
end #TestCases
end #Assertions

