###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test_helper.rb'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
require 'test/test_helper_test_tables.rb'
#require 'test/assertions/generic_table_assertions'
class ColumnGroupTest < ActiveSupport::TestCase
include Generic_Table
include GenericTableAssertion
include GenericTableAssertion::KernelMethods
@@table_name='stream_patterns'
assert_include(ColumnGroup, self.included_modules)
assert_equal('constant', defined? ColumnGroup)
assert(ColumnGroup)
assert_instance_of(Module, ColumnGroup)
assert_equal([ColumnGroup], ColumnGroup.ancestors)
assert_empty(ColumnGroup.included_modules)
assert_equal('constant', defined? ColumnGroup::ClassMethods)

#include ColumnGroup
assert_include(ColumnGroup, self.included_modules)
assert_empty(ColumnGroup.included_modules)

#include ColumnGroup::ClassMethods
assert_equal('constant', defined? ColumnGroup::ClassMethods)
assert_equal([ColumnGroup::ClassMethods], ColumnGroup::ClassMethods.ancestors)

#assert_equal('constant', defined? History_columns)
#assert_equal('constant', defined? ClassMethods::History_columns)
assert_equal('constant', defined? ColumnGroup::ClassMethods::History_columns)
assert_include('History_columns', ColumnGroup::ClassMethods.constants)
assert_empty(ColumnGroup.included_modules)
assert_not_include(ClassMethods, ColumnGroup.included_modules)

#assert_equal(['History_columns'], Module.constants.grep(/History/))
assert_not_empty(Module.constants)
assert_not_empty(ColumnGroup.constants)
History_columns=ColumnGroup::ClassMethods::History_columns
def test_defaulted_primary_logical_key
	assert(StreamPattern.defaulted_primary_logical_key?, "StreamPattern should use the default :name logical_primary_key.")
	assert_not_empty(StreamPattern.column_symbols)
	assert_include('Generic_Table', self.class.included_modules.map{|m| m.name})
	assert_module_included(self.class, Generic_Table)
	assert_defaulted_primary_logical_key(StreamPattern)
	assert_nil(Url.defaulted_primary_logical_key?, "Url uses :href rather than default :name.")
end #defaulted_primary_logical_key
def test_default_logical_primary_key
	model_class=StreamPattern

	assert_equal([:name], model_class.default_logical_primary_key)
end #default_logical_primary_key
def test_logical_primary_key
	CodeBase.rails_MVC_classes.each do |model_class|
		if model_class.defaulted_primary_logical_key? then
			assert_not_empty(model_class.default_logical_primary_key)
		else
			message="model_class.name=#{model_class.name}, "
			message+="model_class.column_symbols=#{model_class.column_symbols.inspect}"
			message+="model_class.logical_primary_key=#{model_class.logical_primary_key.inspect}"
			assert_empty(model_class.logical_primary_key-model_class.column_symbols, message)
			if model_class.sequential_id? then
				message="model_class.name=#{model_class.name}, "
				message+="model_class.column_symbols=#{model_class.column_symbols.inspect}"
				message+="model_class.logical_primary_key=#{model_class.logical_primary_key.inspect}"
				assert_empty(model_class.logical_primary_key-model_class.history_type?, message)
			else
				message="model_class.name=#{model_class.name}, "
				message+="model_class.logical_primary_key=#{model_class.logical_primary_key.inspect}"
				message+="model_class.logical_attributes=#{model_class.logical_attributes.inspect}"
				assert_empty(model_class.logical_primary_key-model_class.logical_attributes, message)
			end #if
		end #if

	end #each
end #logical_primary_key
def test_attribute_ddl
end #attribute_ddl
def test_attribute_ruby_type
	assert_equal(String, StreamPattern.attribute_ruby_type(:name))
	assert_equal(Float, Weather.attribute_ruby_type(:khhr_wind_mph))
	CodeBase.rails_MVC_classes.each do |model_class|
		logical_attributes=model_class.column_names-History_columns
		assert_not_empty(logical_attributes)
		logical_attributes.each do |attribute_name|
			assert_not_nil(model_class.first, "model_class=#{model_class.inspect} has no records.")
			assert_not_nil(model_class.attribute_ruby_type(attribute_name))
#			!model_class.numerical?(name)})
		 end #each
	end #each
end #attribute_ruby_type
def test_attribute_rails_type
	table_sql= self.to_sql
	attribute_sql=table_sql.grep(attribute_name)
	return attribute_sql
end #attribute_rails_type
@@default_connection=StreamPattern.connection
def test_candidate_logical_keys_from_indexes
#?	assert(Frequency.connection.index_exists?(:frequencies,:frequency_name))
	assert_not_nil(StreamPattern.connection)
#bypass	assert(StreamPattern.connection.index_exists?(:stream_patterns,:id, :unique => true))
#	assert(StreamPattern.index_exists?(:id))
	CodeBase.rails_MVC_classes.each do |model_class|
		indexes=model_class.connection.indexes(model_class.name.tableize)
#delay		assert_operator(indexes.size, :<, 2,"test_candidate_logical_keys_from_indexes=#{indexes.inspect}") 
		if indexes.select{|i|i.unique}.size>=2 then
			puts "test_candidate_logical_keys_from_indexes=#{indexes.inspect}"
		end #if
		if indexes != [] then
			indexes.map do |i|
				assert_equal(model_class.name.tableize,i.table)
			end #map
			assert_not_empty(model_class.candidate_logical_keys_from_indexes)
		else
			assert_nil(model_class.candidate_logical_keys_from_indexes)
		end #if
	end #each
end #candidate_logical_keys_from_indexes
def test_numerical
	assert(!StreamPattern.numerical?(:name))
	assert(StreamPattern.numerical?(:created_at))
	assert(StreamPattern.numerical?(:updated_at))
	bug_module_names= Bug.included_modules.map{|m| m.name}.grep(/Generic/)
	assert_include(Generic_Table, Bug.included_modules)
	assert_include(GenericTableAssertion, Bug.included_modules)
	assert_include(GenericTableAssociation, Bug.included_modules)
	assert_include(GenericGrep, Bug.included_modules)
	assert_include(GenericTableHtml, Bug.included_modules)
	assert_equal([ColumnGroupTest], Module.nesting)
	assert_equal([Generic_Table::ClassMethods, Generic_Table], Bug.nesting)
	assert_include(:assert_numerical.to_s, Bug.methods(false))
	Bug.assert_numerical(:id)
	CodeBase.rails_MVC_classes.each do |model_class|
		logical_attributes=model_class.column_names-History_columns
		assert_not_empty(logical_attributes)
		logical_attributes.each do |attribute_name|
			model_class.numerical?(attribute_name)
#			!model_class.numerical?(name)})
		 end #each
	end #each
end #numerical
def test_probably_numerical
end #probably_numerical
def test_categorical
	assert(!GenericType.defaulted_primary_logical_key?)
	assert(GenericType.categorical?(:id))
	assert(GenericType.categorical?(:import_class))
	attribute_name=:generalize_id
	assert_include(attribute_name.to_s, GenericType.foreign_key_names)
	assert(GenericType.foreign_key_names.include?(attribute_name.to_s))
	parent=GenericType.association_class(GenericType.foreign_key_to_association_name(attribute_name))
	parent_keys=parent.logical_primary_key_recursive
	assert_not_nil(GenericType.association_class(GenericType.foreign_key_to_association_name(attribute_name)))
	assert(!parent.sequential_id?)
	assert(GenericType.categorical?(attribute_name), "parent_keys=#{parent_keys.inspect}")
	assert(!StreamPattern.categorical?(:created_at))
	assert(!StreamPattern.categorical?(:updated_at))
	CodeBase.rails_MVC_classes.each do |model_class|
		model_class.column_names.each do |attribute_name|
			classifications=[]
			classifications.push(:numerical) if model_class.numerical?(attribute_name)
			classifications.push(:categorical) if model_class.categorical?(attribute_name)
			classifications.push(:probably_numerical) if model_class.probably_numerical?(attribute_name)
			classifications.push(:probably_categorical) if model_class.probably_categorical?(attribute_name)
			assert_not_empty(classifications, "model_class=#{model_class.inspect}, attribute_name=#{attribute_name}, model_class.logical_primary_key=#{model_class.logical_primary_key.inspect}")
			assert_equal(1, classifications.size, "classifications=#{classifications.inspect}")
		end #each
	end #each
end #categorical
def test_probably_categorical
	assert(StreamPattern.probably_categorical?(:name))
end #probably_categorical
def test_column_symbols
	column_symbols=StreamPattern.column_names.map {|name| name.to_sym}

	assert_equal([:name], column_symbols-History_columns)
end #column_symbols
def test_logical_attributes
	assert_equal([:name], StreamPattern.logical_attributes)
	CodeBase.rails_MVC_classes.each do |model_class|
		logical_attributes=model_class.column_names-History_columns
		assert_not_empty(logical_attributes)
	end #each
end #logical_attributes
def test_is_logical_primary_key
end #logical_primary_key
def test_history_type
	history_types_used=CodeBase.rails_MVC_classes.map do |model_class|
		model_class.history_type?
	end.uniq #map.uniq
	assert_equal([[:id], [:updated_at, :created_at, :id], [:created_at, :id]], history_types_used)
end #history_type
def test_sequential_id
	class_reference=StreamLink
	history_types_not_in_logical_key= class_reference.history_type?-class_reference.logical_primary_key
	assert_equal( history_types_not_in_logical_key, class_reference.history_type?)
	assert(!StreamLink.sequential_id?, "StreamLink=#{StreamLink.column_symbols.inspect}, should not be a sequential_id.")
	model_class=Host
	assert_equal([:name], model_class.logical_primary_key)
	model_class.logical_primary_key.each do |k|
		assert_include(k.to_s, model_class.column_names)
	end #each
	CodeBase.rails_MVC_classes.each do |model_class|
		assert_instance_of(Class, model_class)
		assert_respond_to(model_class, :minimum)
		statistics=model_class.one_pass_statistics(:id)
		id_range=statistics[:max]-statistics[:min]
		if model_class.sequential_id? then
			message= "#{model_class} has a sequential id primary key.\n"
			message+=" Statistics=#{statistics.inspect}\n"
			if statistics[:skewness] > 0 then
				message+=" Maximum #{:id} record=#{model_class.find(statistics[:max_key]).inspect}\n"
			else
				message+=" Minimum #{:id} record=#{model_class.find(statistics[:min_key]).inspect}\n"
			end #if
			message+=", id_range=#{id_range}, possibly failed to specified id in fixture so Rails generated one from the CRC of the fixture label"
			assert_operator(id_range, :<, 100000, message)
		else
			assert_operator(id_range, :>, 100000, "#{model_class.name}.yml probably defines id rather than letting Fixtures define it as a hash.")
			
			model_class.all.each do |record|
				message="record.class.logical_primary_key=#{record.class.logical_primary_key.inspect} recursively expands to record.class.logical_primary_key_recursive=#{record.class.logical_primary_key_recursive.inspect}, "
				message+="record.logical_primary_key_value=#{record.logical_primary_key_value} expands to record.logical_primary_key_recursive_value=#{record.logical_primary_key_recursive_value.inspect}, "
				message+=" identify != id. record.inspect=#{record.inspect} "
				assert_equal(Fixtures::identify(record.logical_primary_key_recursive_value.join(',')),record.id,message)
			end #each_pair

			
			puts "#{model_class.name} has logical primary key of #{model_class.logical_primary_key.inspect} is not a sequential id."
			if model_class.logical_primary_key.is_a?(Array) then
				model_class.logical_primary_key.each do |k|
					assert_include(k.to_s, model_class.column_names)
				end #each
			else
				assert_include(model_class.logical_primary_key,model_class.column_names)
			end #if
		end #if
	end #each
end # sequential_id
def test_logical_primary_key_recursive
	assert_include('logical_primary_key', StreamLink.public_methods(false))
	assert(!StreamLink.sequential_id?, "StreamLink=#{StreamLink.column_symbols.inspect}, should not be a sequential_id.")
	assert(StreamLink.is_foreign_key_name?(:input_stream_method_argument_id), "StreamLink=#{StreamLink.inspect}")
	assert(StreamLink.is_foreign_key_name?(:output_stream_method_argument_id), "StreamLink=#{StreamLink.inspect}")
	link=StreamLink.first
	input_stream_method_argument=link.foreign_key_to_association(:input_stream_method_argument_id)
	assert_not_nil(input_stream_method_argument)
	assert_equal([:name], StreamPattern.logical_primary_key)
	assert_equal({"StreamPattern"=>[:name]}, StreamPattern.logical_primary_key_recursive)
	assert_equal([:stream_method_id, :name], StreamMethodArgument.logical_primary_key)
	assert_equal({"StreamMethodArgument" => [{"StreamMethod"=>[:name]}, :name]}, StreamMethodArgument.logical_primary_key_recursive)
	assert_equal([:name], StreamMethod.logical_primary_key)
	assert_equal({"StreamMethod" => [:name]}, StreamMethod.logical_primary_key_recursive)
	assert_equal([:stream_method_id, :name], input_stream_method_argument.class.logical_primary_key)
	assert_equal({"StreamMethodArgument" => [{"StreamMethod"=>[:name]}, :name]}, input_stream_method_argument.class.logical_primary_key_recursive)
	output_stream_method_argument=link.foreign_key_to_association(:output_stream_method_argument_id)
	assert_not_nil(output_stream_method_argument)
	assert_equal({"StreamMethodArgument" => [{"StreamMethod"=>[:name]}, :name]}, output_stream_method_argument.class.logical_primary_key_recursive)
	assert_equal([:input_stream_method_argument_id, :output_stream_method_argument_id], StreamLink.logical_primary_key)
	assert_equal({"StreamLink" => [{"StreamMethodArgument" => [{"StreamMethod"=>[:name]}, :name]}, {"StreamMethodArgument" => [{"StreamMethod"=>[:name]}, :name]}]}, StreamLink.logical_primary_key_recursive)
end #logical_primary_key_recursive
end #test class
