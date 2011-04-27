require 'test_helper'

class AccountTest < ActiveSupport::TestCase
def setup
	define_association_names
end
def test_general_associations
	assert_general_associations(@table_name)
end
def test_id_and_hash_equal
	@my_fixtures.each_value do |my_fixture|
		assert_equal(Fixtures::identify(my_fixture.logical_primary_key_value),my_fixture.id,"Fixture file test/fixture/#{@table_name}.yml has wrong tag or explicit id, logical_primary_key='#{my_fixture.logical_primary_key}',=#{Fixtures::identify(my_fixture.logical_primary_key)} != my_fixture.id=#{my_fixture.id} where fixture=#{my_fixture.inspect}.")
	end
end #def
end #class
