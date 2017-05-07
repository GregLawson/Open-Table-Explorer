###########################################################################
#    Copyright (C) 2014-2016 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/nested_loop.rb'
class NestedLoopTest < TestCase
#include DefaultTests
	include RailsishRubyUnit::Executable.model_class?::Examples
  def test_NestedLoop_DefinitionalConstants
		Loops.map do |dimension|
			if dimension.methods.include?(:enumerator) then
				index_name = dimension.name.model_name?
				set_instance_variable(index_name, enumerator.next)
			end # if
		end # map
  end # DefinitionalConstants

def test_NestedLoop_next
end # next


def index_name
end # index_name

def test_NestedLoop_next
end # next
end # NestedLoop
