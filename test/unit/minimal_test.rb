###########################################################################
#    Copyright (C) 2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../test/assertions/ruby_assertions.rb'
class MinimalTest < TestCase
def test_assert_array_of
	assert_array_of(['',''], String)
	assert_raise(MiniTest::Assertion){assert_array_of(nil, String)}
end #array_of
end #MinimalTest
