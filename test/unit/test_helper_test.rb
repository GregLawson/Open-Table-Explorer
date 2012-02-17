###########################################################################
#    Copyright (C) 2011-12 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'
#puts "self=#{self.inspect}, methods=#{methods.inspect}"
class TestHelperTest < ActiveSupport::TestCase
set_class_variables(:StreamPattern)
fixtures :table_specs
fixtures :stream_links
#assert_respond_to(ActiveSupport::TestCase, :assert_fixture_name)
#assert_respond_to(self, :assert_fixture_name)
#assert_fixture_name(:stream_links)
#@@my_fixtures=fixtures?(:stream_links)
require 'test/test_helper_test_tables.rb'
def test_class
	assert_instance_of(TestHelperTest, self)
end #test_class
def test_fixtures
	assert_kind_of(ActiveSupport::TestCase, self)
	table_name='table_specs'
	assert_not_nil fixtures?(table_name)
	assert_fixture_name(table_name)
	assert_not_nil fixture_labels(table_name)
#	assert_not_nil model_class(table_specs(:ifconfig))
	assert_not_equal([:stream_links], fixtures?(:stream_links))
	@@my_fixtures=fixtures?(:stream_links)
	assert_fixture_labels
end #fixtures?
def test_fixture_names
	assert_include('stream_patterns',fixture_names)
	assert_include('table_specs',fixture_names)
end #fixture_names
def setup
	@@my_fixtures=fixtures?(@@table_name)
#	define_association_names
end
def test_assert_class_variables_defined
	assert_model_class('EEG')
	assert_model_class('Eeg')
end #assert_class_variables_defined
def test_assert_fixture_label
	assert_model_class(@@model_name)
	assert_not_empty(fixtures?(@@table_name))
	assert_not_empty(fixtures?(@@table_name).to_a[0])
	fixture_as_array=fixtures?(@@table_name).to_a[0]
	fixture_label=fixture_as_array[0]
	ar_from_fixture=fixture_as_array[1]
	assert_instance_of(StreamLink, ar_from_fixture)
	assert_not_nil(StreamLink.association_class(:input_stream_method_argument))
	assert_association(ar_from_fixture.class, :input_stream_method_argument)
	assert_association(ar_from_fixture.class, :output_stream_method_argument)
	assert_foreign_key_not_nil(ar_from_fixture, :input_stream_method_argument)
	assert_foreign_key_not_nil(ar_from_fixture, :output_stream_method_argument)
	assert_fixture_label(fixture_label, ar_from_fixture)
end #assert_fixture_label
end #TestHelperTest

