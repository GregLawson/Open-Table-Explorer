###########################################################################
#    Copyright (C) 2011-12 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################

# File of assertions involving fixtures
class ActiveSupport::TestCase

def assert_fixture_name(table_name)
	assert_include(table_name.to_s,fixture_names)
	assert_not_nil(@loaded_fixtures[table_name.to_s],"table_name=#{table_name.inspect}, fixture_names=#{fixture_names.inspect}")
end #def
def assert_class_variables_defined
	assert_fixture_name(@@table_name)
	assert_instance_of(Hash, fixtures?(@@table_name))
end #assert_class_variables_defined
def assert_fixture_label(fixture_label, ar_from_fixture)
	message="Check that logical key (#{ar_from_fixture.class.logical_primary_key.inspect}"
	message+=" => #{ar_from_fixture.class.logical_primary_key_recursive.inspect})"
	message+=" value (#{ar_from_fixture.logical_primary_key_value} "
	message+="=> #{ar_from_fixture.logical_primary_key_recursive_value.inspect})"
	message+=" exactly matches yaml label(#{fixture_label}) for record."
	assert_equal(fixture_label.to_s, ar_from_fixture.logical_primary_key_recursive_value.join(','), message)
	message=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
#	puts "'#{fixture_label}', #{ar_from_fixture.inspect}"
#	assert(Fixtures::identify(fixture_label), ar_from_fixture.id)
	assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_recursive_value.join(',')),ar_from_fixture.id,message)
end #assert_fixture_label
def assert_fixture_labels
	assert_kind_of(ActiveSupport::TestCase, self)
#	assert_include('@@my_fixtures',ActiveSupport::TestCase.class_variables)
#	assert_include('@@my_fixtures',self.class_variables)
	fixtures?(@@table_name).each_pair do |fixture_label, ar_from_fixture|
		assert_fixture_label(fixture_label, ar_from_fixture)
	end #each_pair
end #assert_id_and_logical_primary_key
def assert_test_id_equal
	assert_class_variables_defined
	if @@model_class.sequential_id? then
	else
		assert_fixture_labels
	end #if
end #assert_test_id_equal
# assert string is the name of an ActiveRecord model and a fixture
def assert_model_class(model_name)
	a_fixture_record=fixtures?(model_name.tableize).values.first
	assert_kind_of(ActiveRecord::Base,a_fixture_record)
	theClass=a_fixture_record.class
	assert_equal(theClass,Generic_Table.eval_constant(model_name))
end #assert_model_class
end #ActiveSupport::TestCase
