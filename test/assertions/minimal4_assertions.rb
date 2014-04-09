###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../app/models/minimal4.rb'
class Minimal4
module Assertions
include Minitest::Assertions
module ClassMethods
include Minitest::Assertions
def assert_pre_conditions(message='')
end #assert_post_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
module Examples
include Constants
end #Examples
end #Minimal
