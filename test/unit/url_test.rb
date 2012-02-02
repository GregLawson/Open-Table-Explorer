###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING pathname that comes with this distribution
#
###########################################################################
require 'test/test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class UrlTest < ActiveSupport::TestCase
@@test_name=self.name
@@model_name=@@test_name.sub(/Test$/, '').sub(/Controller$/, '')
@@model_class=@@model_name.constantize
@@table_name=@@model_name.tableize			
fixtures @@table_name.to_sym
@@my_fixtures=fixtures(@@table_name)
def test_find_by_name
 	assert_equal('EEG', Url.find_by_name('EEG').href)
end #find_by_name
def test_parsedURI
end #def
def test_schemelessUrl
 	assert_equal('/home/greg/Desktop/Downloads/emotive/qdot-emokit-2fa5e40/python/logfile.txt', Url.find_by_name('EEG').schemelessUrl)
end #schemelessUrl
def test_uriComponent
end #end
def test_uriArray
end #def
def test_uriHash
end #def
def test_scheme
end #def
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
	define_model_of_test # allow generic tests
	assert_module_included(@model_class,Generic_Table)
	explain_assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(@model_class,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
#	define_association_names #38271 associations
end #def
def test_general_associations
	assert_general_associations(@table_name)
end #test
def test_id_equal
	assert_fixture_name(@@table_name)
	assert(!@model_class.sequential_id?, "@model_class=#{@model_class}, should not be a sequential_id.")
	assert_instance_of(Hash, fixtures(@@table_name))
	assert_instance_of(Array, @@my_fixtures)
	@@my_fixtures=fixtures(@@table_name)
	assert_instance_of(Hash, @@my_fixtures)
	if @model_class.sequential_id? then
	else
		assert_instance_of(Class, @@model_class)
		assert_instance_of(Array, @@model_class.logical_primary_key, "For simplicity, logical_primary_key=#{@@model_class.logical_primary_key.inspect} should be an array even when its a single component.")
		assert_operator(@@model_class.logical_primary_key.size, :<=, 3, "logical_primary_key=#{@@model_class.logical_primary_key.inspect} has more components than is usual.")
		@@my_fixtures.each_pair do |key, ar_from_fixture|
			message="Check that logical key (#{ar_from_fixture.class.logical_primary_key.inspect}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label(#{key}) for record."
			message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
			puts "'#{key}', #{ar_from_fixture.inspect}"
			assert(Fixtures::identify(key), ar_from_fixture.id)
			assert_equal(ar_from_fixture.logical_primary_key_recursive_value.join(','), key.to_s,message)
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_recursive_value),ar_from_fixture.id,message)
		end
	end
end #def
def test_specific__stable_and_working
end #test
def test_aaa_test_new_assertions_ # aaa to output first
#	assert_equal(@my_fixtures,fixtures(@table_name))
end #test
end #class
