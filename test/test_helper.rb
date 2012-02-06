###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'test/assertions/ruby_assertions.rb'
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
#  fixtures :all

  # Add more helper methods to be used by all tests here...
require 'test/assertions/generic_table_assertions.rb'
# flexible access to all fixtures
def fixtures(table_name)
	table_name=table_name.to_s
	assert_fixture_name(table_name)
	assert_not_empty(fixture_labels(table_name))
	assert_not_empty(@loaded_fixtures[table_name])
	assert_instance_of(Array,fixture_labels(table_name))
	fixture_hash={}
	@loaded_fixtures[table_name].each do |f|
		if f.at(0).nil? then # *.csv format?
			raise "fixture label undefined for *.csv files."
		else
			fixture_label=f.at(0)
		end #if
		assert_not_nil(fixture_label,"f=#{f.inspect}, fixture_names=#{fixture_names.inspect}")
		if fixture_label.instance_of?(String) then
			fixture_label=fixture_label.to_sym
		end
		assert_not_nil(fixture_label)
		fixture_data=f.at(1)
		ar_from_fixture=fixture_data.model_class.new(fixture_data.to_hash)
		if ar_from_fixture.id.nil? and !fixture_data.to_hash['id'].nil? then # id not set in new
			assert_nil(ar_from_fixture['id'],"ar_from_fixture=#{ar_from_fixture.inspect}")
			assert_nil(ar_from_fixture[:id])
			assert_nil(ar_from_fixture.id)
			assert_equal(ar_from_fixture.id,ar_from_fixture['id'])
			assert_equal(ar_from_fixture.id,ar_from_fixture[:id])
			assert_not_nil(fixture_data.to_hash['id'] )
			assert_not_equal(fixture_data.to_hash['id'] ,fixture_data.to_hash[:id] )
			
			ar_from_fixture[:id]=fixture_data.to_hash['id'] # lost by new
			assert_not_nil(ar_from_fixture[:id])
			assert_equal(ar_from_fixture.id,ar_from_fixture[:id])
			assert_equal(ar_from_fixture.id,ar_from_fixture['id'])

			ar_from_fixture.id=fixture_data.to_hash['id'] # lost by new
			assert_not_nil(ar_from_fixture.id)
			assert_equal(ar_from_fixture.id,ar_from_fixture[:id])
			assert_equal(ar_from_fixture.id,ar_from_fixture['id'])
		else
			assert_not_empty(ar_from_fixture.id)
			assert_equal(ar_from_fixture.id,ar_from_fixture[:id])
			assert_equal(ar_from_fixture.id,ar_from_fixture['id'])
		end
		assert_not_nil(ar_from_fixture['id'])
		assert_not_nil(ar_from_fixture[:id])
		assert_not_nil(ar_from_fixture.id)
		assert_instance_of(fixture_data.model_class,ar_from_fixture)
	#	puts " ar_from_fixture.inspect=#{ ar_from_fixture.inspect}"
	#	puts " ar_from_fixture.instance_variables.inspect=#{ ar_from_fixture.instance_variables.instance_variables.inspect}"
		#~ puts " ar_from_fixture.model_class.inspect=#{ ar_from_fixture.model_class.inspect}"
		#~ puts " ar_from_fixture.to_hash.inspect=#{ ar_from_fixture.to_hash.inspect}"
		#~ puts " ar_from_fixture.key_list.inspect=#{ ar_from_fixture.key_list.inspect}"
		#~ puts " ar_from_fixture.value_list.inspect=#{ ar_from_fixture.value_list.inspect}"
	#	puts " ar_from_fixture.ar_from_fixture.inspect=#{ ar_from_fixture.ar_from_fixture.inspect}"
		assert_respond_to(ar_from_fixture.class,:sequential_id?,"sequential_id? ar_from_fixture.inspect=#{ar_from_fixture.inspect}")
	#	puts " ar_from_fixture.class.table_name.inspect=#{ ar_from_fixture.class.table_name.inspect}"
	#	puts " ar_from_fixture.class.name.inspect=#{ ar_from_fixture.class.name.inspect}"
		assert_not_nil(ar_from_fixture['id'],"ar_from_fixture.id is nil. From hash=#{fixture_data.to_hash.inspect} into in ar_from_fixture.inspect=#{ar_from_fixture.inspect}")
		if ar_from_fixture.class.sequential_id? then
		else
			assert_equal(Fixtures::identify(fixture_label),ar_from_fixture.id,"#{table_name}.yml probably defines id rather than letting Fixtures define it as a hash.")
		end #if
		fixture_hash[fixture_label]=ar_from_fixture
	end #each
	return fixture_hash
end #fixtures

# http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
def fixture_names
	@loaded_fixtures.keys
end #fixture_names
def assert_fixture_name(table_name)
	assert_include(table_name.to_s,fixture_names)
	assert_not_nil(@loaded_fixtures[table_name.to_s],"table_name=#{table_name.inspect}, fixture_names=#{fixture_names.inspect}")
end #def
def fixture_labels(table_name)
	@fixture_labels=@loaded_fixtures[table_name.to_s].collect do |fix|
#		puts "fix.at(0)=#{fix.at(0).inspect}"
		fix.at(0)
	end #collect
end #def

# does not require any fixtures
def define_model_of_test 
	@test_name=self.class.name
	assert_equal('Test',@test_name[-4..-1],"@test_name='#{@test_name}' does not follow the default naming convention.")
	@model_name=@test_name.sub(/Test$/, '').sub(/Controller$/, '')
 	@table_name=@model_name.tableize
	@model_class=eval(@model_name)
	@model_class=@model_name.constantize
	assert_instance_of(Class,@model_class)
	if !Generic_Table.is_ActiveRecord_table?(@model_class.name) then
		puts "#{@model_class} is not a ActiveRecord::Base."
	end #if
#	assert_ActiveRecord_table(@model_class.name)
#	assert_kind_of(ActiveRecord::Base,@model_class)
#	assert_kind_of(ActiveRecord::Base,@model_class.new)
end #def
MESSAGE_CONTEXT="In define_association_names of test_helper.rb, "
def define_association_names
	define_model_of_test
	assert_model_class(@model_name)
	assert_fixture_name(@table_name)
	assert_not_nil(@loaded_fixtures)
	@my_fixtures=fixtures(@table_name)
	@fixture_labels=fixture_labels(@table_name)
	@assignable_ids=@model_class.instance_methods(false).grep(/_ids=$/ )
	@assignable=(@model_class.instance_methods(false).grep(/=$/ )-@assignable_ids).collect {|m| m[0..-2] }
	@assignable_ids_to_many=@model_class.instance_methods(false).grep(/_ids=$/ ).collect {|m| m[0..-6] }
	@ids_to_many=@model_class.instance_methods(false).grep(/_ids$/ ).collect {|m| m[0..-5] }
	assert_has_instance_methods(@model_class,MESSAGE_CONTEXT)
	assert_has_associations(@model_class,MESSAGE_CONTEXT)
#	puts "@model_class.instance_methods(false)=#{@model_class.instance_methods(false).inspect}"
	assert_not_empty(@model_class.instance_methods(false).grep(/=$/ ))
	#~ puts "@model_class.instance_methods(false).grep(/=$/ )=#{@model_class.instance_methods(false).grep(/=$/ ).inspect}"
	#~ puts "@assignable=#{@assignable.inspect}"
	#~ puts "@assignable_ids_to_many=#{@assignable_ids_to_many.inspect}"
	assert_not_empty(@model_class.instance_methods(false).grep(/=$/ )-@model_class.column_names.grep(/_ids=$/))
	@possible_associations=(@assignable&@model_class.instance_methods(false))
	assert_not_empty(@possible_associations)
#	puts "@possible_associations.inspect=#{@possible_associations.inspect}"
 	@possible_many_associations=@assignable_ids_to_many&@ids_to_many&@model_class.instance_methods(false)&@assignable
#	puts "@possible_many_associations.inspect=#{@possible_many_associations.inspect}"
	#~ @content_column_names=@model_class.content_columns.collect {|m| m.name}
	#~ puts "@content_column_names.inspect=#{@content_column_names.inspect}"
	#~ @special_columns=@model_class.column_names-@content_column_names
	#~ puts "@special_columns.inspect=#{@special_columns.inspect}"
	@possible_foreign_keys=@model_class.foreign_key_names
end #def
def self.set_class_variables
	@@test_name=self.name
	@@model_name=@@test_name.sub(/Test$/, '').sub(/Controller$/, '')
	@@model_class=@@model_name.constantize
	@@table_name=@@model_name.tableize
	fixtures @@table_name.to_sym
end #set_class_variables
def assert_class_variables_defined
	assert_fixture_name(@@table_name)
	assert(!@@model_class.sequential_id?, "@@model_class=#{@@model_class}, should not be a sequential_id.")
	assert_instance_of(Hash, fixtures(@@table_name))
	@@my_fixtures=fixtures(@@table_name)
	assert_instance_of(Hash, @@my_fixtures)
end #assert_class_variables_defined
def assert_id_and_logical_primary_key(ar_from_fixture, key)
	message="Check that logical key (#{ar_from_fixture.class.logical_primary_key.inspect} => #{ar_from_fixture.class.logical_primary_key_recursive.inspect}) value (#{ar_from_fixture.logical_primary_key_value} => #{ar_from_fixture.logical_primary_key_recursive_value.inspect}) exactly matches yaml label(#{key}) for record."
	assert_equal(ar_from_fixture.logical_primary_key_recursive_value.join(','), key.to_s,message)
	message=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
#	puts "'#{key}', #{ar_from_fixture.inspect}"
#	assert(Fixtures::identify(key), ar_from_fixture.id)
	assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_recursive_value.join(',')),ar_from_fixture.id,message)
end #assert_id_and_logical_primary_key
def assert_test_id_equal
	assert_class_variables_defined
	if @@model_class.sequential_id? then
	else
		@@my_fixtures.each_pair do |key, ar_from_fixture|
			assert_id_and_logical_primary_key(ar_from_fixture, key)
		end #each_pair
	end #if
end #
end #class
