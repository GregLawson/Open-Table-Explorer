###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions/minimal4_assertions.rb'
class Minimal4AssertionsTest < TestCase
include DefaultTests
include Unit::Executable.model_class?::Examples
end #Minimal
