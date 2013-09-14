###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class Minimal
module Constants
end #Constants
include Constants
module ClassMethods
end #ClassMethods
extend ClassMethods
#include DefaultAssertions
#extend DefaultAssertions::ClassMethods
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
#self.assert_pre_conditions
module Examples
include Constants
end #Examples
include Examples
end #Minimal
