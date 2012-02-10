###########################################################################
#    Copyright (C) 2011-12 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class ActiveSupport::TestCase

def assert_fixture_name(table_name)
	assert_include(table_name.to_s,fixture_names)
	assert_not_nil(@loaded_fixtures[table_name.to_s],"table_name=#{table_name.inspect}, fixture_names=#{fixture_names.inspect}")
end #def
def assert_class_variables_defined
	assert_fixture_name(@@table_name)
	assert_instance_of(Hash, fixtures(@@table_name))
	assert_instance_of(Hash, @@my_fixtures)
end #assert_class_variables_defined
def assert_fixture_labels
	assert_instance_of(TestHelperTest, self)
	assert_kind_of(ActiveSupport::TestCase, self)
#	assert_include('@@my_fixtures',ActiveSupport::TestCase.class_variables)
#	assert_include('@@my_fixtures',self.class_variables)
	fixtures?(@@table_name).each_pair do |key, ar_from_fixture|
		message="Check that logical key (#{ar_from_fixture.class.logical_primary_key.inspect} => #{ar_from_fixture.class.logical_primary_key_recursive.inspect}) value (#{ar_from_fixture.logical_primary_key_value} => #{ar_from_fixture.logical_primary_key_recursive_value.inspect}) exactly matches yaml label(#{key}) for record."
		assert_equal(key.to_s, ar_from_fixture.logical_primary_key_recursive_value.join(','), message)
		message=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
	#	puts "'#{key}', #{ar_from_fixture.inspect}"
	#	assert(Fixtures::identify(key), ar_from_fixture.id)
		assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_recursive_value.join(',')),ar_from_fixture.id,message)
	end #each_pair
end #assert_id_and_logical_primary_key
def assert_test_id_equal
	assert_class_variables_defined
	if @@model_class.sequential_id? then
	else
		assert_fixture_labels(ar_from_fixture, key)
	end #if
end #assert_test_id_equal
end #ActiveSupport::TestCase
