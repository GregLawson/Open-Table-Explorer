###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# File of ActiveRecord and NoDB assertions.
# Favorite test case for associations
@@CLASS_WITH_FOREIGN_KEY=StreamPatternArgument
@@FOREIGN_KEY_ASSOCIATION_CLASS=StreamPattern
@@FOREIGN_KEY_ASSOCIATION_SYMBOL=:stream_pattern # needs correct plurality
@@FOREIGN_KEY_ASSOCIATION_INSTANCE=@@FOREIGN_KEY_ASSOCIATION_CLASS.where(:name => 'Acquisition').first
@@TABLE_NAME_WITH_FOREIGN_KEY=@@CLASS_WITH_FOREIGN_KEY.name.tableize

@@association_patterns=Set[/^build_([a-z0-9_]+)$/, /^([a-z0-9_]+)=$/, /^autosave_associated_records_for_([a-z0-9_]+)$/, /^set_([a-z0-9_]+)_target$/, /^loaded_([a-z0-9_]+)?$/, /^create_([a-z0-9_]+)$/, /^([a-z0-9_]+)$/]
#	@@example_class_reference=StreamPattern
#	@@example_association_reference=:stream_methods
	@@example_class_reference=@@CLASS_WITH_FOREIGN_KEY
	@@example_association_reference=@@FOREIGN_KEY_ASSOCIATION_SYMBOL

module GenericTableAssertion
include Test::Unit
module KernelMethods
def association_refs(class_reference=@@example_class_reference, association_reference=@@example_association_reference, &block)
	if class_reference.kind_of?(Class) then
		klass=class_reference
	else
		klass=class_reference.class
	end #if
	association_reference=association_reference.to_sym
	block.call(class_reference, association_reference)
end #association_refs
# assertions testing single generic_table methods
def all_foreign_key_associations(&block)
	Generic_Table.rails_MVC_classes.each do |class_with_foreign_key|
		class_with_foreign_key.foreign_key_association_names.each do |foreign_key_association_name|
			block.call(class_with_foreign_key, foreign_key_association_name)
		end #each
	end #each
end #all_associations
#
# assertions not directly testing single generic_table methods
#
def assert_association_one_to_one(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"assert_association_one_to_one")
	assert_association_to_one(ar_from_fixture,assName)
end #association_one_to_one
def assert_association_one_to_many(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"assert_association_one_to_many")
	assert_association_to_many(ar_from_fixture,assName)
end #association_one_to_many
def assert_association_many_to_one(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"assert_association_many_to_one")
	assert_association_to_one(ar_from_fixture,assName)
end #association_many_to_one
def assert_model_grep(model_reference,grep_pattern)
	assert_not_equal("", model_reference.model_grep(grep_pattern), "grep_pattern=#{grep_pattern}")
end #model_grep
def assert_has_many_association(class_reference, association_name)
	assert(class_reference.association_grep('has_many',association_name))
end #has_many_association
def assert_belongs_to_association(model_class,association_name)
	assert_instance_of(Class, model_class)
	assert_instance_of(Class, model_class, "model_class=#{model_class.inspect} is of type #{model_class.class.name} but should be Class.")
	correct_plurality=model_class.association_method_plurality(association_name)
	assert_association(model_class, correct_plurality)
	assert_association(model_class,association_name, "plurality should be #{correct_plurality}")
	assert_association_to_one(model_class,association_name)
	assert_include(association_name.to_s,model_class.foreign_key_association_names)
end #belongs_to_association
def assert_defaulted_primary_logical_key(class_reference)
	message="#{class_reference.name} uses "
	message+="#{class_reference.logical_primary_key.inspect} rather than default "
#	message+="#{class_reference.superclass.logical_primary_key.inspect}"
	assert(class_reference.defaulted_primary_logical_key?, message)
end #defaulted_primary_logical_key
def assert_associations(ass1,ass2,message=nil)
	message=build_message(message, "ass1=? ass2=?", ass1.inspect, ass2.inspect)	
	class1=ass1.to_s.classify.constantize # must succeed
	association_symbol2=class1.association_method_symbol(ass2)
	assert_association(class1,association_symbol2, message)
	if class1.association_default_class_name?(ass2) then
		class2=class1.association_class(association_symbol2)
		assert_kind_of(Class,class1.association_class(ass2), message)
		assert_kind_of(Symbol,class2.association_method_symbol(ass1), message)
		assert_association(class1.association_class(ass2),class2.association_method_symbol(ass1), message)
	end #if
end #assert_associations
def assert_general_associations(table_name)
	fixtures(table_name).each_value do |fixture|
	fixture.class.association_names.each do |association_name|
		assert_associations(table_name,association_name)
		assName=association_name.to_sym
		if fixture.class.is_association_to_many?(assName) then
			 assert_association_to_many(fixture.class,assName)
#GENERALIZE			assert_foreign_key_points_to_me(fixture,assName)
		else
			assert_association_to_one(fixture.class,assName)
		end #if
	end #each
#	assert_equal(Fixtures::identify(fixture.logical_prmary_key),fixture.id,"identify != id")
	end #each
end #assert_general_associations
def assert_foreign_key_points_to_me(ar_from_fixture,assName)
	assert_association(ar_from_fixture.class,assName)
	associated_records=ar_from_fixture.associated_foreign_key_records(assName)
	assert_not_empty(associated_records,"assert_foreign_key_points_to_me ar_from_fixture.inspect=#{ar_from_fixture.inspect},assName=#{assName} Check if id is specified in #{assName.to_sym}.yml file.")
end #foreign_key_points_to_me
def assert_active_record_method(method_name)
	assert(ActiveRecord::Base.is_active_record_method?(method_name))
end #assert_active_record_method
def assert_not_active_record_method(method_name)
	assert(!ActiveRecord::Base.is_active_record_method?(method_name))
end #assert_not_active_record_method
def assert_table_exists(table_name)
	message="#{'table_name'.titleize} #{table_name} does not exist as a database table."
	assert_block(message){Generic_Table.table_exists?(table_name)}
end #assert_table_exists
def assert_table(table_name)
	message="#{'table_name'.titleize} #{table_name} does not exist and may be misspelled."
	assert_block(message){Generic_Table.is_table?(table_name)}
end #assert_table
def assert_ActiveRecord_table(model_class_name)
	assert_table(model_class_name.tableize)
	message="#{'model_class_name'.titleize} #{model_class_name} is not an ActiveRecord table."
	assert_block(message){Generic_Table.is_ActiveRecord_table?(model_class_name)}
end #assert_ActiveRecord_table
def assert_generic_table(model_class_name)
	assert_no_match(/_ids$/,model_class_name,"Table name should not end in _ids to avoid confusion with to many associations.")
	assert_ActiveRecord_table(model_class_name)
	message="#{'model_class_name'.titleize} #{model_class_name} is not a Generic Table."
	assert_block(message){Generic_Table.is_generic_table?(model_class_name)}
end #assert_generic_table
# assert that an association named association_reference exists  in class class_reference as well as an association named class_reference.name  exists  in class association_reference
def assert_matching_association(table_reference,association_name)
	table_class=Generic_Table.class_of_name(table_reference)
	assert_association(table_class,association_name)

	association_class=table_class.association_class(association_name)
	assert_not_nil(association_class)
	table_symbol=association_class.association_method_symbol(table_reference)
	assert(association_class.is_association?(table_symbol) ,"#{association_class.inspect}.is_association?(#{table_symbol})")

	
	
	assert_association(association_class,table_symbol)
	#~ assert_belongs_to(table_reference,association_name) 
	#~ assert_belongs_to(association_name,table_reference) 
	message="Table name #{table_symbol.to_s} do not have matching associations (has* declarations) with #{'association_name'.titleize} #{association_name}."
	assert_block(message){table_class.is_matching_association?(association_name)}
end  #assert_matching_association
def assert_has_associations(model_class,message='')
	message=build_message(message, "? has no associations. #{model_class.name}.rb is missing has_* or belongs_to macros.", model_class.canonicalName)   
	assert_block(message){!model_class.association_names.empty?}	
end #has_associations
end #module KernelMethods
end #Module GenericTableAssertions
module ActiveRecord
class Base
include Test::Unit
include GenericTableAssertion
# Is attribute an numerical (analog) (versus categorical (digital) value)
# default logical primary keys ignore analog values
# Statistical procedures will treat these attributes as continuous
# override for specific classes
# by default the following are considered analog:
#  Float
#  Time
#  DateTime
#  id for sequential_id?
def Base.assert_numerical(attribute_name)
	message=build_message(message, "numerical self=?, attribute_name=?", self.inspect, attribute_name)
	assert_block(message){numerical?(attribute_name)}
end #numerical
def Base.assert_probably_numerical(attribute_name)
	message=build_message(message, "probably_numerical self=?, attribute_name=?", self.inspect, attribute_name)
	assert_block(message){probably_numerical?(attribute_name)}
end #probably_numerical
def Base.assert_categorical(attribute_name)
	message=build_message(message, "categorical self=?, attribute_name=?", self.inspect, attribute_name)
	assert_block(message){categorical?(attribute_name)}
end #categorical
def Base.assert_probably_categorical(attribute_name, message)
	message=build_message(message, "probably_categorical self=?, attribute_name=?", self.inspect, attribute_name)
	assert_block(message){probably_categorical?(attribute_name)}
end #probably_categorical
end #Base
end #ActiveRecord

