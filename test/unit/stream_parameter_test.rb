###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'

class StreamParameterTest < ActiveSupport::TestCase
set_class_variables
def test_id_equal
	assert(!@@model_class.sequential_id?, "@@model_class=#{@@model_class}, should not be a sequential_id.")
	assert_test_id_equal
end #id_equal
def test_foreign_keys_not_nil
	@@model_class.assert_foreign_keys_not_nil
end #
end #StreamParameterTest
