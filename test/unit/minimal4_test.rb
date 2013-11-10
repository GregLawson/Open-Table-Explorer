###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions/minimal4_assertions.rb'
class Minimal4Test < TestCase
include DefaultTests
include TE.model_class?::Examples
def test_Constants
end #Constants
def test_initialize
end #initialize
end #Minimal
