###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment' # avoid recursive requires
require 'test/unit'
#require_relative '../../test/assertions/ruby_assertions.rb'
TestCase=BaseTestCase=Test::Unit::TestCase
class MinimalTest < TestCase
#include TE.model_class?::Examples
end #Minimal
