###########################################################################
#    Copyright (C) 2014-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/minimal2.rb'
class Minimal2Test < TestCase
include DefaultTests
include TE.model_class?::Examples
end # Minimal2
