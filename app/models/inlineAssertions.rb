###########################################################################
#    Copyright (C) 2010 by Greg Lawson                                      
#    <GregLawson@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/unit/assertions'
class Class
include Test::Unit::Assertions
end #class
module Inline_Assertions
include Test::Unit::Assertions
end #module
module Inline_Assertions_Stubs #no ops
include Test::Unit::Assertions
def assert_block(message="") #{|| ...}
end #def
end #module
class Test_Assertion
include Inline_Assertions
def test
	assert_equal(1,1)
end #def
end #class
