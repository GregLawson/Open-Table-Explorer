###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative 'default_test_case.rb'
require_relative '../../app/models/generic_table_association.rb'
require 'active_support/all'
require 'set'
require 'active_record'
require_relative '../../app/models/generic_table.rb'
require_relative '../../app/models/stream_pattern_argument.rb'
require_relative '../../app/models/stream_pattern.rb'
require_relative '../../app/models/stream_link.rb'
require_relative '../../app/models/stream_method.rb'
require_relative '../../app/models/stream_link.rb'
require_relative '../../app/models/no_db.rb'
require_relative '../test_helper_test_tables.rb'
class GenericTableAssociationTest < ActiveSupport::TestCase
include DefaultTests2
#include Generic_Table
#include GenericTableAssertions
@@table_name='stream_patterns'
#fixtures @@table_name.to_sym
#	fixtures :table_specs
#	fixtures :acquisition_stream_specs
#	fixtures :acquisition_interfaces
#	fixtures :acquisitions
def test_foreign_key_names
	content_column_names=StreamPatternArgument.content_columns.collect {|m| m.name}
	assert_include('stream_pattern_id',StreamPatternArgument.column_names)
	special_columns=StreamPatternArgument.column_names-content_column_names
	assert_include('stream_pattern_id',special_columns)
	assert_equal(['stream_pattern_id','parameter_id'],StreamPatternArgument.foreign_key_names)
	assert_not_empty(StreamPatternArgument.foreign_key_names)
	possible_foreign_keys=StreamPatternArgument.foreign_key_names
	assert_not_empty(possible_foreign_keys)
	assert_include('stream_pattern_id',possible_foreign_keys)

	assert_foreign_key_name(StreamLink,:input_stream_method_argument_id)
end #foreign_key_names
def test_foreign_key_name
	assert(!StreamLink.is_foreign_key_name?(:junk))
	assert(!StreamLink.is_foreign_key_name?(:junk_id))
	assert(StreamLink.is_association?(StreamLink.foreign_key_to_association_name(:input_stream_method_argument_id)))
	assert(StreamLink.is_foreign_key_name?(:input_stream_method_argument_id), "StreamLink=#{StreamLink.inspect}")
	assert(StreamLink.is_foreign_key_name?(:output_stream_method_argument_id), "StreamLink=#{StreamLink.inspect}")
end #foreign_key_name
def test_foreign_key_to_association_name
	assert_equal('parameter', ActiveRecord::Base.foreign_key_to_association_name(:parameter_id))
end #foreign_key_to_association_name
def test_foreign_key_association_names
	assert_include('stream_pattern_id',StreamPatternArgument.foreign_key_names)
	assert_include('stream_pattern',StreamPatternArgument.foreign_key_names.map {|fk| fk.sub(/_id$/,'')})
	assert_foreign_key_association_names(StreamMethod,:stream_pattern)
end #foreign_key_association_names

def test_associated_foreign_key_name
	many_to_one_foreign_keys=StreamPatternArgument.foreign_key_names
	assert_not_empty(many_to_one_foreign_keys)
	matchingAssNames=many_to_one_foreign_keys.select do |fk|
		ass=fk[0..-4].to_sym
		ass==:stream_pattern
	end #end
	assert_equal(1, matchingAssNames.size)
	assert_equal(@@FOREIGN_KEY_ASSOCIATION_SYMBOL.to_s+'_id',@@CLASS_WITH_FOREIGN_KEY.associated_foreign_key_name(@@FOREIGN_KEY_ASSOCIATION_SYMBOL))
end #associated_foreign_key_name
def test_associated_foreign_key_records
	assert_equal(@@FOREIGN_KEY_ASSOCIATION_SYMBOL.to_s+'_id',@@CLASS_WITH_FOREIGN_KEY.associated_foreign_key_name(@@FOREIGN_KEY_ASSOCIATION_SYMBOL))
	expected_association=@@CLASS_WITH_FOREIGN_KEY.where(@@FOREIGN_KEY_ASSOCIATION_SYMBOL.to_s+'_id' => @@FOREIGN_KEY_ASSOCIATION_INSTANCE[:id])
	assert_equal(2,expected_association.count)
	assert_instance_of(Fixnum,@@FOREIGN_KEY_ASSOCIATION_INSTANCE[:id])
	assert_equal([@@FOREIGN_KEY_ASSOCIATION_INSTANCE[:id]],expected_association.map {|ar| ar.stream_pattern_id}.uniq)
	assert_instance_of(@@FOREIGN_KEY_ASSOCIATION_CLASS,@@FOREIGN_KEY_ASSOCIATION_INSTANCE)
	assert_equal(@@FOREIGN_KEY_ASSOCIATION_CLASS,@@FOREIGN_KEY_ASSOCIATION_INSTANCE.class)
	assert_kind_of(ActiveRecord::Base,@@FOREIGN_KEY_ASSOCIATION_INSTANCE)
	assert_equal(@@CLASS_WITH_FOREIGN_KEY,@@FOREIGN_KEY_ASSOCIATION_INSTANCE.class.association_class(@@TABLE_NAME_WITH_FOREIGN_KEY))
	assert_equal(@@FOREIGN_KEY_ASSOCIATION_SYMBOL.to_s+'_id',@@CLASS_WITH_FOREIGN_KEY.associated_foreign_key_name(@@FOREIGN_KEY_ASSOCIATION_SYMBOL))
	assert_equal(expected_association,@@CLASS_WITH_FOREIGN_KEY.where(@@FOREIGN_KEY_ASSOCIATION_SYMBOL.to_s+'_id' => @@FOREIGN_KEY_ASSOCIATION_INSTANCE[:id]))
	assert_equal(expected_association,@@FOREIGN_KEY_ASSOCIATION_INSTANCE.associated_foreign_key_records(@@TABLE_NAME_WITH_FOREIGN_KEY))
	assert_equal(2,@@FOREIGN_KEY_ASSOCIATION_INSTANCE.associated_foreign_key_records(@@TABLE_NAME_WITH_FOREIGN_KEY).count)
end #associated_foreign_key_records
def test_is_matching_association
	 assert_association(@@CLASS_WITH_FOREIGN_KEY,@@FOREIGN_KEY_ASSOCIATION_SYMBOL)
#	 association_class=@@CLASS_WITH_FOREIGN_KEY.association_class(@@FOREIGN_KEY_ASSOCIATION_SYMBOL)
	 association_class=@@FOREIGN_KEY_ASSOCIATION_CLASS.association_class(@@TABLE_NAME_WITH_FOREIGN_KEY)
	assert_equal(association_class,@@CLASS_WITH_FOREIGN_KEY)
	assert_not_nil(association_class)
	assert_equal(@@FOREIGN_KEY_ASSOCIATION_SYMBOL,association_class.association_method_symbol(@@FOREIGN_KEY_ASSOCIATION_SYMBOL))
	assert(@@CLASS_WITH_FOREIGN_KEY.is_matching_association?(@@FOREIGN_KEY_ASSOCIATION_SYMBOL))
	assert(TableSpec.is_matching_association?(:frequency))
	assert_matching_association(TableSpec, :frequency)

end #matching_association

def test_association_methods
	class_reference=@@FOREIGN_KEY_ASSOCIATION_CLASS
	association_reference=@@TABLE_NAME_WITH_FOREIGN_KEY

	assert_equal_sets(["stream_pattern_arguments=", "validate_associated_records_for_stream_pattern_arguments","autosave_associated_records_for_stream_pattern_arguments", "stream_pattern_arguments"],class_reference.association_methods(association_reference))
end #association_methods
Array_of_patterns=
@@fk_association_patterns=Set[/^autosave_associated_records_for_([a-z0-9_]+)$/, /^([a-z0-9_]+)=$/, /^validate_associated_records_for_([a-z0-9_]+)$/, /^([a-z0-9_]+)$/]
def test_association_patterns
	class_reference=@@FOREIGN_KEY_ASSOCIATION_CLASS
	association_reference=@@TABLE_NAME_WITH_FOREIGN_KEY.to_sym
	matchData=Regexp.new(association_reference.to_s).match(association_reference.to_s)
	assert_equal("^([a-z0-9_]+)$",'^'+matchData.pre_match+'([a-z0-9_]+)'+matchData.post_match+'$')
	assert_equal_sets(@@fk_association_patterns,class_reference.association_patterns(association_reference))
end #association_patterns
def test_match_association_patterns
	class_reference=@@FOREIGN_KEY_ASSOCIATION_CLASS
	association_name=@@TABLE_NAME_WITH_FOREIGN_KEY
#	assert(class_reference.instance_respond_to?(association_name))
	assert(class_reference.match_association_patterns?(association_name,association_name))
end #match_association_patterns
def test_is_association_patterns
	class_reference=@@FOREIGN_KEY_ASSOCIATION_CLASS
	association_reference=@@TABLE_NAME_WITH_FOREIGN_KEY
	assert_equal_sets(@@fk_association_patterns,class_reference.association_patterns(association_reference))
	assert_empty(@@fk_association_patterns-class_reference.association_patterns(association_reference))
	assert_empty(class_reference.association_patterns(association_reference)-@@fk_association_patterns)
	assert(class_reference.is_association_patterns?(association_reference,@@fk_association_patterns))
end #is_association_patterns
def test_is_association
		class_reference=StreamLink
		association_reference=:inputs
	ActiveRecord::Base.association_refs do |class_reference, association_reference|
	#  For instance, attributes and connection would be bad choices for association names.
		assert_include('attributes',ActiveRecord::Base.instance_methods_from_class, "# Don't create associations that have the same name (#{association_reference})as instance methods of ActiveRecord::Base (#{ActiveRecord.instance_methods_from_class}).")
		assert_include('connection',ActiveRecord::Base.instance_methods_from_class, "# Don't create associations that have the same name (#{association_reference})as instance methods of ActiveRecord::Base (#{ActiveRecord.instance_methods_from_class}).")
		assert_not_include(association_reference.to_s,ActiveRecord::Base.instance_methods_from_class, "# Don't create associations that have the same name (#{association_reference})as instance methods of ActiveRecord::Base (#{ActiveRecord.instance_methods_from_class}).")
		explain_assert_respond_to(class_reference.new,(association_reference.to_s+'=').to_sym)
		explain_assert_respond_to(class_reference.new,association_reference.to_s,"association_reference=#{association_reference.to_s}, ")
		assert(class_reference.is_association?(association_reference),"fail is_association?, class_reference.inspect=#{class_reference.inspect},association_reference=#{association_reference}")
	end #association_refs
end #is_association
def test_is_association_to_one
	class_reference=StreamPatternArgument
	association_reference=:stream_pattern
	explain_assert_respond_to(class_reference.new,(association_reference.to_s.singularize+'_id').to_sym)
	explain_assert_respond_to(class_reference.new,(association_reference.to_s.singularize+'_id=').to_sym)
	assert(class_reference.is_association?(association_reference),"fail is_association?, class_reference.inspect=#{class_reference.inspect},association_reference=#{association_reference}")
	assert(class_reference.is_association_to_one?(association_reference),"fail is_association?, class_reference.inspect=#{class_reference.inspect},association_reference=#{association_reference}")
end #is_association_to_one
def test_is_association_to_many
	class_reference=@@FOREIGN_KEY_ASSOCIATION_CLASS
	association_reference=@@TABLE_NAME_WITH_FOREIGN_KEY
	explain_assert_respond_to(class_reference.new,(association_reference.to_s.singularize+'_ids').to_sym)
	explain_assert_respond_to(class_reference.new,(association_reference.to_s.singularize+'_ids=').to_sym)
	assert(class_reference.is_association?(association_reference),"fail in is_association_to_many?, class_reference.inspect=#{class_reference.inspect},association_reference=#{association_reference}")
	assert(class_reference.is_association_to_many?(association_reference),"fail is_association?, class_reference.inspect=#{class_reference.inspect},association_reference=#{association_reference}")
end #is_association_to_many
def test_is_polymorphic_association
	@possible_nonpolymorphic_methods=Set.new(["create_stream_pattern", "stream_pattern=", "build_stream_pattern", "set_stream_pattern_target", "stream_pattern", "loaded_stream_pattern?", "autosave_associated_records_for_stream_pattern"])
	assert_equal(@possible_nonpolymorphic_methods,Set.new(StreamPatternArgument.matching_instance_methods(:stream_pattern.to_s)))
	@example_nonpolymorphic_patterns=Set.new([/^build_([a-z0-9_]+)$/, /^([a-z0-9_]+)=$/,/^autosave_associated_records_for_([a-z0-9_]+)$/, /^set_([a-z0-9_]+)_target$/, /^loaded_([a-z0-9_]+)?$/, /^create_([a-z0-9_]+)$/, /^([a-z0-9_]+)$/])
	assert_equal_sets(@example_nonpolymorphic_patterns,Set.new(StreamPatternArgument.association_patterns(:stream_pattern.to_s)))

#	@example_polymorphic_class=Node
#	@example_polymorphic_association=:branch
	class_reference=Node
	association_name=:branch
	assert_association(class_reference, association_name)
	
	@possible_polymorphic_methods=Set.new(["autosave_associated_records_for_branch","loaded_branch?", "set_branch_target", "branch","branch="])
	assert_equal_sets(@possible_polymorphic_methods,Set.new(class_reference.matching_instance_methods(association_name.to_s)))

	@example_polymorphic_patterns=Set.new([/^([a-z0-9_]+)$/, /^set_([a-z0-9_]+)_target$/, /^([a-z0-9_]+)=$/, /^autosave_associated_records_for_([a-z0-9_]+)$/, /^loaded_([a-z0-9_]+)?$/])
	assert_equal_sets(@example_polymorphic_patterns,Set.new(class_reference.association_patterns(association_name.to_s)))

	@possible_polymorphic_patterns2=Set.new(["", "autosave_associated_records_for_", "validate_associated_records_for_","="])
	@common_patterns=@example_nonpolymorphic_patterns & @example_polymorphic_patterns
	
#	assert(@example_polymorphic_patterns.all? { |a| class_reference.instance_respond_to?(a)})

#	assert(@example_polymorphic_patterns.all? { |a| class_reference.instance_respond_to?(a)})

	assert(class_reference.is_polymorphic_association?(association_name))
end #is_polymorphic_association
def test_association_names_to_one
end #association_names_to_one
def test_association_names_to_many
	class_reference=StreamLink
	assert(class_reference.instance_methods(false).select {|m| class_reference.is_association_to_many?(m)})
end #association_names_to_many
def test_association_names
	class_reference=StreamLink
	assert_not_empty(class_reference.instance_methods(false).select {|m| class_reference.is_association?(m)})
	assert_not_include('bug_ids', TestRun.association_names_to_one)
	assert_equal([],TestRun.association_names_to_one)
	assert_not_include('bug_ids', TestRun.association_names_to_many)
	assert_equal(['bugs'],TestRun.association_names_to_many)
	assert_not_include('bug_ids', TestRun.association_names)
	assert_equal(['bugs'],TestRun.association_names)
end #association_names
def test_name_symbol
	assert_equal(:stream_methods, StreamPattern.name_symbol(StreamMethod))
	assert_equal(:stream_methods, StreamPattern.name_symbol('stream_methods'))
	assert_equal(:stream_methods, StreamPattern.name_symbol('stream_method'))
	assert_equal(:stream_methods, StreamPattern.name_symbol('StreamMethod'))
	assert_equal(:oxen, StreamPattern.name_symbol('ox'))
	assert_equal(:bases, StreamPattern.name_symbol('base'))
	assert_equal(:ox, StreamPattern.name_symbol(:ox))
	assert_equal(:base, StreamPattern.name_symbol(:base))
	assert_equal(:stream_methods, StreamPattern.name_symbol(:stream_methods))
end #name_symbol
def test_association_method_plurality
	assert_equal(:full_associated_models,TestTable.association_method_plurality(:full_associated_models))
	assert_equal(:full_associated_models,TestTable.association_method_plurality(:full_associated_model))
	assert_equal(:full_associated_models,TestTable.association_method_plurality(:full_associated_model))
	assert_equal(:stream_pattern,StreamPatternArgument.association_method_plurality(:stream_patterns))
	assert_equal(:stream_pattern,StreamPatternArgument.association_method_plurality(:stream_pattern))
	assert_equal(:stream_pattern,StreamPatternArgument.association_method_plurality(:stream_patterns))
end #association_method_plurality
def test_association_method_symbol
	assert_equal(:full_associated_models,TestTable.association_method_symbol(:full_associated_models))
	assert_equal(:full_associated_models,TestTable.association_method_symbol(:full_associated_model))
	
	assert_public_instance_method(StreamPatternArgument.new,:stream_pattern)
	assert_equal(:stream_pattern,StreamPatternArgument.association_method_symbol(:stream_pattern))
	assert_equal(:stream_pattern,StreamPatternArgument.association_method_symbol(:stream_patterns))
	 association_class=@@FOREIGN_KEY_ASSOCIATION_CLASS.association_class(@@TABLE_NAME_WITH_FOREIGN_KEY)
	assert_equal(association_class,@@CLASS_WITH_FOREIGN_KEY)
	assert_equal(@@FOREIGN_KEY_ASSOCIATION_SYMBOL,association_class.association_method_symbol(@@FOREIGN_KEY_ASSOCIATION_SYMBOL))
end #association_method_symbol
def test_association_default_class_name
	class_reference=StreamLink
	association_name='input_stream_method_argument'
	assert_nil(class_reference.association_default_class_name?(association_name))
	assert_equal("StreamPattern", StreamPatternArgument.association_default_class_name?(:stream_pattern))
end #association_default_class_name
def test_Base_association_class
	assert_equal(StreamPattern, StreamMethod.association_class(:stream_patterns))
	assert_equal("VARCHAR_Column", GenericType.find_by_import_class('Integer_Column').generalize.import_class)
	assert_equal(GenericType, GenericType.find_by_import_class('Integer_Column').generalize.class)
	assert_equal(GenericType, GenericType.find_by_import_class('alnum').specialize[0].class)
	assert_equal(Array, GenericType.find_by_import_class('alnum').specialize.class)
	assert_equal(GenericType, GenericType.association_class(:generalize))
	assert_equal(GenericType, GenericType.association_class(:specialize))

	 assert_association(@@CLASS_WITH_FOREIGN_KEY,@@FOREIGN_KEY_ASSOCIATION_SYMBOL)
	assert_equal(@@FOREIGN_KEY_ASSOCIATION_CLASS,@@CLASS_WITH_FOREIGN_KEY.association_class(@@FOREIGN_KEY_ASSOCIATION_SYMBOL))
	class_reference=StreamLink
	association_name='input_stream_method_argument'
	all_parents=class_reference.all
	all_association_classes=all_parents.map do |bc|
		bc.association_class(association_name)
	end.flatten.uniq #map
	assert_instance_of(Array, all_association_classes)
	assert_single_element_array(all_association_classes)
end #Base_association_class
def test_association_arity
	class_reference=StreamLink
	association_reference=:inputs
	ActiveRecord::Base.association_refs do |class_reference, association_reference|
		assert_association_to_one(class_reference,association_reference)
		if class_reference.module_included?(Generic_Table) then
			association_type=class_reference.association_arity(association_reference)
			assert_not_nil(association_type)
			assert_include(association_type,[:to_one,:to_many])
		end #if
	end #association_refs
end #association_arity
def test_name_to_association
	class_reference=StreamLink
	association_name='input_stream_method_argument'
	obj=class_reference.first
	assert_not_nil(obj.name_to_association(association_name), "obj=#{obj.inspect}, StreamMethodArgument.all=#{StreamMethodArgument.all.inspect}")
end #name_to_association
def test_foreign_Key_to_association
	assert_not_nil(StreamMethod.first.foreign_key_to_association(:stream_pattern_id))
end #foreign_Key_to_association
def test_association_class
	assert_equal(StreamPattern, StreamMethod.first.association_class(:stream_pattern))
	integerColumn=GenericType.find_by_import_class('Integer_Column')
	alnum=GenericType.find_by_import_class('alnum')
	assert_equal(Array, alnum.specialize.class)
	assert_equal(GenericType, integerColumn.association_class(:generalize))
	assert_equal(GenericType, alnum.association_class(:specialize))

	 assert_association(@@CLASS_WITH_FOREIGN_KEY,@@FOREIGN_KEY_ASSOCIATION_SYMBOL)
	assert_equal(@@FOREIGN_KEY_ASSOCIATION_CLASS,@@CLASS_WITH_FOREIGN_KEY.association_class(@@FOREIGN_KEY_ASSOCIATION_SYMBOL))
	class_reference=StreamLink
	association_name='input_stream_method_argument'
	assert_association(class_reference, association_name)
	instance=class_reference.first
	association=instance.name_to_association(association_name)
	assert_instance_of(StreamMethodArgument, association)
	if association.instance_of?(Array) then
		classes=association.enumerate(:map){|r| r.class}.uniq
		if classes.size==1 then
			assert_single_element_array(association)
		else
			assert_instance_of(Array, association)
		end #if
	else
		assert_instance_of(Class, association.enumerate(:map){|r| r.class})
	end #if
	assert_equal(StreamMethodArgument, class_reference.first.association_class(association_name))
end #association_class

def test_foreign_key_points_to_me
end #foreign_key_points_to_me
def test_logical_primary_key_recursive_value
	assert_include('logical_primary_key', StreamLink.public_methods(false))
	assert(!StreamLink.sequential_id?, "StreamLink=#{StreamLink.column_symbols.inspect}, should not be a sequential_id.")
	assert_equal([:input_stream_method_argument_id, :output_stream_method_argument_id], StreamLink.logical_primary_key)
	assert(StreamLink.is_foreign_key_name?(:input_stream_method_argument_id), "StreamLink=#{StreamLink.inspect}")
	assert(StreamLink.is_foreign_key_name?(:output_stream_method_argument_id), "StreamLink=#{StreamLink.inspect}")
	link=StreamLink.first
	assert_not_equal(link[:input_stream_method_argument_id], link[:output_stream_method_argument_id])
	input_stream_method_argument=link.foreign_key_to_association(:input_stream_method_argument_id)
	assert_not_nil(input_stream_method_argument)
	assert_equal({"StreamMethodArgument"=>[{"StreamMethod"=>[:name]}, :name]}, input_stream_method_argument.class.logical_primary_key_recursive)
	assert_equal([["File"], "acquisitions"], input_stream_method_argument.logical_primary_key_recursive_value)
	output_stream_method_argument=link.foreign_key_to_association(:output_stream_method_argument_id)
	assert_not_nil(output_stream_method_argument)
	assert_not_equal(input_stream_method_argument, output_stream_method_argument)
	assert_equal([["Regexp"], "acquisitions"], output_stream_method_argument.logical_primary_key_recursive_value)
	StreamLink.all.each do |link|
		assert_equal(4, link.logical_primary_key_recursive_value.flatten.size)
		assert_not_equal(link[:input_stream_method_argument_id], link[:output_stream_method_argument_id])
	end #each
end #logical_primary_key_recursive_value
def test_logical_primary_key_value
end #logical_primary_key_value
def test_associated_to_s
	acquisition_stream_spec=acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym)

	acquisition_stream_spec.associated_to_s(:acquisition_interface,:name)
	assert_instance_of(String,acquisition_stream_spec.associated_to_s(:acquisition_interface,:name))
	assert_respond_to(acquisition_stream_spec,:associated_to_s)
	assert_equal('',acquisitions(:one).associated_to_s(:acquisition_stream_spec,:url))
	acquisitions(:one).acquisition_stream_spec_id=nil
	assert_equal('',acquisitions(:one).associated_to_s(:acquisition_stream_spec,:url))
	acquisitions(:one).acquisition_stream_spec_id=0

	assert_not_nil(acquisition_stream_spec)
#	puts acquisition_stream_spec.matching_instance_methods(/table_spec/).inspect
#	puts acquisition_stream_spec.class.similar_methods(:table_spec).inspect
	assert_respond_to(acquisition_stream_spec,:table_spec)
	meth=acquisition_stream_spec.method(:table_spec)
	
	assert_not_empty(StreamPatternArgument.foreign_key_names)
	assert_include('stream_pattern_id',StreamPatternArgument.foreign_key_names)
	assert_include('stream_pattern',StreamPatternArgument.foreign_key_association_names)
	

	#~ explain_assert_respond_to(TestTable.new,:generic_table_associated_model)
	#~ explain_assert_respond_to(TestTable.new,:stream_method_id)
	#~ assert_association(TestTable.new,:generic_table_associated_model)
	#~ assert_association_to_one(TestTable.new,:generic_table_associated_model)
	#~ ass=TestTable.send(:stream_method_id)
	#~ assert_not_nil(ass)
	#~ associations_foreign_key_name=(TestTable.name.tableize.singularize+'_id').to_sym
	#~ assert_include(associations_foreign_key_name,TestTable.foreign_key_association_names)
	#~ associations_foreign_key_values=ass.map { |a| a.send(associations_foreign_key_name) }.uniq.join(',')
	#~ assert_not_empty(ass.map { |a| a.send(associations_foreign_key_name) })
	#~ assert_not_empty(ass.map { |a| a.send(associations_foreign_key_name) }.uniq)
	#~ assert_not_empty(ass.map { |a| a.send(associations_foreign_key_name) }.uniq.join(','))
	#~ assert_not_empty(associations_foreign_key_values, "Association #{assName}'s foreign key #{associations_foreign_key_name} has value #{associations_foreign_key_values} and returns type #{ass.class.name}.")

	
#	assert_not_nil(meth.call)
#	ass=acquisition_stream_spec.send(:table_spec)
#	if ass.nil? then
#		return ''
#	else
#		return ass.send(:model_class_name,*args).to_s
#	end
#	puts "acquisition_stream_spec.associated_to_s(:table_spec,:model_class_name)=#{acquisition_stream_spec.associated_to_s(:table_spec,:model_class_name)}"
end #associated_to_s
def test_matching_associations
	assert_equal(["frequency_id"],TableSpec.foreign_key_names)

	assert_equal("Acquisition","acquisitions".classify)
	assert_equal("Acquisition",Acquisition.name)
	assert_equal("acquisitions",Acquisition.table_name)
	assert_equal("Acquisition".tableize,"acquisitions")
	assert(Generic_Table.table_exists?("acquisitions".tableize))
	

	assert_respond_to(TableSpec.new,:frequency)
	assert_nil(TableSpec.new.frequency)
	assert_association(TableSpec.new,"frequency")
	assert(TableSpec.is_matching_association?("frequency"))
	assert_association(Frequency.new,"table_specs")
	assert_equal('frequencies',Frequency.table_name)
	assert(TableSpec.is_association?(Frequency.table_name.singularize))
end #matching_associations
#end #Module GenericTableAssertions
#module ActiveRecord
#class Base
def test_Base_assert_foreign_keys_not_nil
	class_reference=StreamLink
	class_reference.assert_foreign_keys_not_nil
end #assert_foreign_keys_not_nil
def test_assert_foreign_keys_not_nil
	class_reference=StreamLink
	assert_equal(['input_stream_method_argument_id','output_stream_method_argument_id',"store_method_id","next_method_id"], class_reference.foreign_key_names)
	class_reference.first.assert_foreign_keys_not_nil
end #assert_foreign_keys_not_nil
# display possible foreign key values when nil foreign keys values are found
def test_assert_foreign_key_not_nil
	class_reference=StreamLink
	association_name='input_stream_method_argument'
	assert_association(class_reference, association_name)
	assert_not_nil(class_reference.association_class(association_name))
	association_class=StreamMethodArgument	
	class_reference.all.each do |r|
		assert_not_nil(association_class)
		possible_foreign_key_values=association_class.all.map do |fkacr|
			fkacr.logical_primary_key_recursive_value.join(',')
		end.uniq #map
		assert_not_empty(possible_foreign_key_values, "as no foreign keys.")
		message=possible_foreign_key_values.join("\n")

		assert_not_nil(r.foreign_key_value(association_name), message)
	end #each
	assert_foreign_key_not_nil(StreamLink.first, :input_stream_method_argument, StreamMethodArgument)
end #assert_foreign_key_not_nil
test 'Inter-model associations' do
#	puts "model_classes=#{model_classes.inspect}"
	CodeBase.rails_MVC_classes.each do |class_with_foreign_key|
		if !class_with_foreign_key.module_included?(:Generic_Table) then
			puts "#{class_with_foreign_key.name} does not include Generic_Table"
		else
			table_name_with_foreign_key=class_with_foreign_key.name
			class_with_foreign_key.foreign_key_association_names.each do |foreign_key_association_name|
				if !class_with_foreign_key.is_association?(foreign_key_association_name) then
					puts "#{foreign_key_association_name} is not an association of #{class_with_foreign_key.name}"
				elsif class_with_foreign_key.belongs_to_association?(foreign_key_association_name) then
					puts "#{table_name_with_foreign_key} belongs_to #{foreign_key_association_name}"
					if !Generic_Table.rails_MVC_class?(foreign_key_association_name) then
						puts "#{foreign_key_association_name} is not a generic table in #{CodeBase.rails_MVC_classes.map {|c| c.name}.inspect}."
					elsif !class_with_foreign_key.module_included?(:Generic_Table) then
						puts "#{class_with_foreign_key.name} does not include Generic_Table"
					else
						if foreign_key_association_name.classify.constantize.has_many_association?(table_name_with_foreign_key) then
							puts "#{foreign_key_association_name} has_many #{table_name_with_foreign_key}"
						else
							puts "#{foreign_key_association_name} does not has_many #{table_name_with_foreign_key}"					
						end #if
					end #if
				else
					if !class_with_foreign_key.module_included?(:Generic_Table) then
						puts "#{class_with_foreign_key.name} does not include Generic_Table"
					else
						puts "#{table_name_with_foreign_key} does not have a belongs_to #{foreign_key_association_name}"
						if foreign_key_association_name.classify.constantize.has_many_association?(table_name_with_foreign_key) then
							puts "#{foreign_key_association_name} has_many #{table_name_with_foreign_key}"
						else
							puts "#{foreign_key_association_name} does not has_many #{table_name_with_foreign_key}"					
						end #if
					end #if
				end #if
	#			fixtures(table_name)
			end #each
		end #if
	end #each
end #test
def test_Association_Progression
	assert(FullAssociatedModel.instance_respond_to?(:test_table))
	assert(HalfAssociatedModel.instance_respond_to?(:test_table))
	assert(!GenericTableAssociatedModel.instance_respond_to?(:test_table))
	assert(!EmptyAssociatedModel.instance_respond_to?(:test_table))
	assert(!EmptyClass.new.respond_to?(:test_table))

	assert_equal(:to_one, FullAssociatedModel.association_arity(:test_table))
	assert_equal(:to_one, HalfAssociatedModel.association_arity(:test_table))
	assert_equal(:not_an_association, GenericTableAssociatedModel.association_arity(:test_table))
	assert_equal(:not_an_association, EmptyAssociatedModel.association_arity(:test_table))
	
	assert(TestTable.instance_respond_to?(:full_associated_models))
	assert(!TestTable.instance_respond_to?(:half_associated_model))
	assert(!TestTable.instance_respond_to?(:generic_table_associated_model))
	assert(!TestTable.instance_respond_to?(:empty_associated_model))

	assert_equal(:to_many,TestTable.association_arity(:full_associated_models))
	assert_equal(:not_an_association,TestTable.association_arity(:half_associated_model))
	assert_equal(:not_an_association,TestTable.association_arity(:generic_table_associated_model))
	assert_equal(:not_an_association,TestTable.association_arity(:empty_associated_model))

	assert(TestTable.is_association?(:full_associated_models))
	assert_equal('test_tables',TestTable.table_name)
	#~ assert(FullAssociatedModel.is_association?(TestTable.table_name),"FullAssociatedModel.is_association?(#{TestTable.table_name})")
	assert(FullAssociatedModel.is_association?(:test_table))
	association_class=TestTable.association_class(:full_associated_models)
	assert(association_class.is_association?(association_class.association_method_symbol(TestTable.table_name.singularize.to_sym)) ,"#{association_class.inspect}.is_association?(#{association_class.association_method_symbol(TestTable.table_name.singularize.to_sym)})")
	assert(TestTable.is_matching_association?(:full_associated_models))
end #test

end # GenericTableAssociation
