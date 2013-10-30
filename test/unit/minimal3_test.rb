###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions/minimal3_assertions.rb'
class Minimal3Test < TestCase
include DefaultTests
include TE.model_class?::Examples
end #Minimal
