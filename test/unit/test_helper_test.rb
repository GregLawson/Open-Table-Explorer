require 'test/test_helper'
puts "self=#{self.inspect}, methods=#{methods.inspect}"
class TestHelperTest < ActiveSupport::TestCase
@@table_name='stream_patterns'
fixtures @@table_name.to_sym
fixtures :table_specs
fixtures :stream_links
assert_respond_to(ActiveSupport::TestCase, :assert_fixture_name)
assert_respond_to(self, :assert_fixture_name)
assert_fixture_name(:stream_links)
@@my_fixtures=fixtures(:stream_links)
require 'test/test_helper_test_tables.rb'
def test_fixtures
	table_name='table_specs'
	assert_not_nil fixtures(table_name)
	assert_fixture_name(table_name)
	assert_not_nil fixture_labels(table_name)
#	assert_not_nil model_class(table_specs(:ifconfig))
	assert_not_equal([:stream_links], fixtures(:stream_links))

	@@my_fixtures.each_pair do |key, ar_from_fixture|
		message="Check that logical key (#{ar_from_fixture.logical_primary_key}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label for record."
		message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
		assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,message)
		assert(Fixtures::identify(key), ar_from_fixture.id)
	end #each_pair
end #fixtures
def test_fixture_names
	assert_include('stream_patterns',fixture_names)
	assert_include('table_specs',fixture_names)
end #fixture_names
def setup
#	define_association_names
end
def testMethod
	return 'nice result'
end #def

end #class

