###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit'
require_relative 'assertions/ruby_assertions.rb'
module Assertions
#include Minitest::Assertions
include Test::Unit::Assertions
module ClassMethods
#include Minitest::Assertions
include Test::Unit::Assertions
def assert_pre_conditions(message='')
	message+="In #{self.class}::assert_pre_conditions, self=#{inspect}"
	assert_respond_to(self, :assert_not_nil)
end #assert_pre_conditions
#ClassMethods.assert_pre_conditions
end #ClassMethods
#ClassMethods.assert_pre_conditions
#self.assert_pre_conditions
extend ClassMethods
end #Assertions
include Assertions
extend Assertions::ClassMethods
self.assert_pre_conditions
