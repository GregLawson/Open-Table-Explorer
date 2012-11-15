###########################################################################
#    Copyright (C) 2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../test/assertions/ruby_assertions.rb'
class Minimal
require_relative '../assertions/default_assertions.rb'
module Assertions
module ClassMethods
end #ClassMethods
end #Assertions
include Assertions
extend Assertions::ClassMethods
include DefaultAssertions
extend DefaultAssertions::ClassMethods
include TestCaseHelpers
extend TestCaseHelpers
module TestCases
	Constant=1
	def dummy
		assert_respond_to(TestCases, :constants_by_class)
	end #dummy
	def self.class_dummy
		puts "TestCases.inspect=#{TestCases.inspect}"
		puts "TestCases.constants.inspect=#{TestCases.constants.inspect}"
		puts "TestCases.instance_methods.inspect=#{TestCases.instance_methods.inspect}"
		puts "TestCases.methods.inspect=#{TestCases.methods.inspect}"
	end #dummy
end #TestCases
end #Minimal
