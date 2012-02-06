###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'

class StreamMethodArgumentTest < ActiveSupport::TestCase
set_class_variables
def test_id_equal
	assert_class_variables_defined
	assert_fixture_name(@@table_name)
	assert(!@@model_class.sequential_id?, "@model_class=#{@model_class}, should not be a sequential_id.")
	assert_instance_of(Hash, fixtures(@@table_name))
	@@my_fixtures=fixtures(@@table_name)
	assert_instance_of(Hash, @@my_fixtures)
	if @@model_class.sequential_id? then
	else
		@@my_fixtures.each_pair do |key, ar_from_fixture|
			assert_id_and_logical_primary_key(ar_from_fixture, key)
		end #each_pair
	end #if
end #test_id_equal
end #StreamMethodArgument
