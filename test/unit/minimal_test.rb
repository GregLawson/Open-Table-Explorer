###########################################################################
#    Copyright (C) 2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions/minimal_assertions.rb'
require_relative '../../test/unit/default_assertions_test.rb'
class MinimalTest < TestCase
include DefaultAssertions
extend DefaultAssertions::ClassMethods
include DefaultAssertionTests
end #MinimalTest
