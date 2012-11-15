###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit'
require_relative '../../app/models/unbounded_fixnum.rb'
require_relative '../../test/assertions/ruby_assertions.rb'
# Extention of FixNum class to unbounded limits
# nil means unbounded (i.e. infinity)
class UnboundedFixnum < Numeric # Fixnum blocks new
require_relative '../../test/unit/test_environment'
require_relative '../assertions/default_assertions.rb'
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
# conditions true while class is being defined
def assert_pre_conditions
	assert_invariant
end #assert_pre_conditions
# conditions that are always true (at least atomically)
def assert_invariant
	assert_include(UnboundedFixnum.ancestors, Numeric)
end #class_invariant_conditions
# Post conditions are true after an operation
end #ClassMethods
# Instance methods
def assert_invariant
	self.class.assert_invariant
	if @fixnum.nil? then
		assert_not_nil(@infinity_sign)
		assert_instance_of(Fixnum, @infinity_sign)
		assert(@infinity_sign==-1 || @infinity_sign==+1)
	else
		assert_instance_of(Fixnum, @fixnum)
	end #if
end #assert_invariant

end #Assertions
include Assertions
extend Assertions::ClassMethods
include DefaultAssertions
extend DefaultAssertions::ClassMethods
module TestCases
Example=UnboundedFixnum.new(3)
include Constants
end #TestCases
end #UnboundedFixnum
