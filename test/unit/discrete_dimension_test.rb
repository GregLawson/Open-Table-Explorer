###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/discrete_dimension.rb'
class DiscreteDimensionTest < TestCase
include DefaultTests
include TE.model_class?::Examples
def test_next
	assert_equal(:passed, Branches.next)
end #next
end #DiscreteDimension
