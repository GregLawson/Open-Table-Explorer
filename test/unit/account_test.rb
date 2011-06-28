require 'test_helper'

class AccountTest < ActiveSupport::TestCase
def setup
	define_association_names
end
def test_general_associations
	assert_general_associations(@table_name)
end
def test_id_equal
	if @model_class.new.sequential_id? then
	else
		@my_fixtures.each_value do |ar_from_fixture|
			message="Check that logical key (#{ar_from_fixture.logical_primary_key}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label for record."
			message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,message)
		end
	end
end #def
end #class
