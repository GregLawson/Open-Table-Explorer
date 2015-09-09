###########################################################################
#    Copyright (C) 2014-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment_minitest.rb'
#puts 'self.class.constants = ' + self.class.constants.inspect
fail 'in assertions.rb AssertionsModule not found in ' + self.class.constants.inspect unless self.class.constants.include?(:AssertionsModule)
#puts Module.constants.inspect
#puts "\nself.class.constants = " + self.class.constants.inspect
require_relative '../../test/assertions/ruby_assertions.rb'
#fail 'in assertions.rb AssertionsModule not found in ' + self.class.constants.inspect unless self.class.constants.include?(:AssertionsModule)
module Assertions
include AssertionsModule
extend AssertionsModule
#include Test::Unit::Assertions
module ClassMethods
#include Minitest::Assertions
#include Test::Unit::Assertions
include AssertionsModule
def assert_pre_conditions(message='')
	message+="In #{self.class}::assert_pre_conditions, self=#{inspect}"
	assert_respond_to(self, :refute_nil)
end #assert_pre_conditions
#ClassMethods.assert_pre_conditions
end #ClassMethods
#ClassMethods.assert_pre_conditions
#self.assert_pre_conditions
extend ClassMethods
end # Assertions
#include Assertions
#extend Assertions::ClassMethods
#self.assert_pre_conditions
