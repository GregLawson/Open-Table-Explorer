require 'test_helper'
# executed in alphabetical orer? Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class TestRunTest < ActiveSupport::TestCase
def assert_logical_primary_key_defined(instance)
	assert_not_nil(instance)
	assert_instance_of(TestRun,instance)
	assert_kind_of(ActiveRecord::Base,instance)

	puts "instance=#{instance.inspect}"
	assert_not_nil(instance.attributes)
	assert_not_nil(instance['test_type'])
	assert_not_nil(instance[:test_type])
	assert_not_nil(instance.test_type)
	assert_not_nil(instance.test_type)
	assert_not_nil(instance.model)
end #assert_logical_primary_key_defined
test 'initialize' do
	assert_logical_primary_key_defined(TestRun.new({:test_type => :unit, :model => 'test_runs'}))
	assert_not_nil(ENV["TABLE"])
	test=TestRun.new(:unit)
	assert_logical_primary_key_defined(test)
	
end #initialize
test 'ruby_run_and_log' do
	TestRun.ruby_run_and_log('/dev/null','/dev/null')
end #ruby_run_and_log
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
	define_model_of_test # allow generic tests
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	define_association_names
end #def
def test_general_associations
	assert_general_associations(@table_name)
end #test
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
test "specific, stable and working" do
end #test
test "aaa test new assertions" do  # aaa to output first
	assert_equal(@my_fixtures,fixtures(@table_name))
end #test
end #class
