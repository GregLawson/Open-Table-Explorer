###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative 'default_test_case.rb'
require_relative '../../app/models/stream_method_argument.rb' # in test_helper?

class StreamMethodArgumentTest < DefaultTestCase2
include DefaultTests2
def test_id_equal
	assert(!model_class?.sequential_id?, "model_class?=#{model_class?}, should not be a sequential_id.")
#	assert_test_id_equal
end #test_id_equal
end #StreamMethodArgument
