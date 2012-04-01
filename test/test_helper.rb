###########################################################################
#    Copyright (C) 2011-12 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################

# File for general test and fixture methods
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
require 'test/assertions/fixture_assertions.rb'
#require 'test/assertions/generic_table_assertions.rb'
# access to any fixture by name
def fixtures?(table_name)
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
		fixture_hash[fixture_label]=ar_from_fixture
	end #each
	return fixture_hash
end #fixtures?

# http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
def fixture_names
	@loaded_fixtures.keys
end #fixture_names
def fixture_labels(table_name)
	@fixture_labels=@loaded_fixtures[table_name.to_s].collect do |fix|
#		puts "fix.at(0)=#{fix.at(0).inspect}"
		fix.at(0)
	end #collect
end #def

# set up variables
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
def define_association_names
	message="In define_association_names of test_helper.rb, "
	define_model_of_test
	assert_model_class(@model_name)
	assert_fixture_name(@table_name)
	assert_not_nil(@loaded_fixtures)
	@my_fixtures=fixtures?(@table_name)
	@fixture_labels=fixture_labels(@table_name)
	@assignable_ids=@model_class.instance_methods(false).grep(/_ids=$/ )
	@assignable=(@model_class.instance_methods(false).grep(/=$/ )-@assignable_ids).collect {|m| m[0..-2] }
	@assignable_ids_to_many=@model_class.instance_methods(false).grep(/_ids=$/ ).collect {|m| m[0..-6] }
	@ids_to_many=@model_class.instance_methods(false).grep(/_ids$/ ).collect {|m| m[0..-5] }
	assert_has_instance_methods(@model_class,message)
	assert_has_associations(@model_class,message)
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
# allow customization for tests without models (test_helper_test.rb) and without .yml fixtures (EEG).
def self.set_class_variables(model_name=self.name.sub(/Test$/, '').sub(/Controller$/, ''), fixture_load=true)
#class	assert_instance_of(TestHelperTest, self)
	@@model_name=model_name.to_s
	@@table_name=@@model_name.tableize
#	require "test/unit/#{@@table_name.singularize}_test.rb"
	if File.exists?("test/fixtures/#{@@table_name}.yml") then
		fixtures @@table_name.to_sym if fixture_load
	end #if
	@@model_class=Generic_Table.class_of_name(@@model_name)
end #set_class_variables
end #ActiveSupport::TestCase
