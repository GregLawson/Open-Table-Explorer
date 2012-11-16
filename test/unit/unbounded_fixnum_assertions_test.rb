###########################################################################
#    Copyright (C) 2010-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions/unbounded_fixnum_assertions.rb'
require_relative '../../test/unit/default_assertions_test.rb'
class UnboundedFixnumAssertionsTest < TestCase
include UnboundedFixnum::Examples
include DefaultAssertionTests
end #UnboundedFixnum
