###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require 'test/test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class NetworkTest < ActiveSupport::TestCase
@@test_name=self.name
#        assert_equal('Test',@@test_name[-4..-1],"@test_name='#{@test_name}' does not follow the default naming convention.")
@@model_name=@@test_name.sub(/Test$/, '').sub(/Controller$/, '')
@@table_name=@@model_name.tableize
#@@my_fixtures=fixtures(@@table_name)
 
fixtures @@table_name.to_sym
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
	define_model_of_test # allow generic tests
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement. Sequential id is a class method.")
	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	define_association_names
end #def
def test_whereAmI
	acquire=StreamPattern.find_by_name('Acquisition')
	assert_not_nil(acquire, "StreamPattern=#{StreamPattern.all.map{|p| p.name}.inspect}")
	ifconfig=StreamMethod.find_by_name('Shell')
	assert_not_nil(ifconfig, "StreamMethod=#{StreamMethod.all.inspect}")
	explain_assert_respond_to(ifconfig, :compile_code)
	explain_assert_respond_to(ifconfig, :fire)
	Network.whereAmI
end #whereAmI
def test_general_associations
#more fixtures need to be loaded?	assert_general_associations(@table_name)
end #test
def test_id_equal
	if @model_class.sequential_id? then
	else
		@my_fixtures.each_value do |ar_from_fixture|
			message="Check that logical key (#{ar_from_fixture.logical_primary_key}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label for record."
			message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,message)
		end
	end
end #def
def test_specific__stable_and_working
end #test
def test_aaa_test_new_assertions_ # aaa to output first
	assert_equal(fixtures(@table_name), @my_fixtures)
end #test
end #class
