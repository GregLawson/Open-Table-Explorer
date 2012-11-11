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
end #Assertions

