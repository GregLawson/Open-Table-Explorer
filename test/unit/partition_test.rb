###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require 'test/test_helper'
class PartitionTest < ActiveSupport::TestCase
set_class_variables
def test_initialize
end #initialize
def test_all
	url=Url.find_by_name('partitions')
	assert_not_nil(url)
	stream_method=url.stream_method
	assert_not_nil(stream_method)
	stream_method.compile_code!
	stream_method.fire!
	records=@@model_class.all
	assert_not_empty(records)
end #all
def test_column_symbols
	assert_include('sample', BatteryMeasurement.methods)
	wanted_columns=[:device, :blocks, :id, :created_at, :updated_at]
	column_names=@@model_class.column_symbols
	assert_equal([], column_names-wanted_columns, "Unwanted columns:")
end #column_symbols
end #PartitionTest
