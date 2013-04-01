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
def assert_foreign_key_name(class_reference, foreign_key_name)
	if !class_reference.kind_of?(Class) then
		class_reference=class_reference.class
	end #if
	if !foreign_key_name.kind_of?(String) then
		foreign_key_name=foreign_key_name.to_s
	end #if
	assert_block("foreign_key_name=#{foreign_key_name} is not a foreign key of class_reference=#{class_reference.inspect}"){class_reference.foreign_key_names.include?(foreign_key_name)}
end #assert_foreign_key_name
def assert_foreign_key_association_names(class_reference,association_reference)
	assert_include(association_reference.to_s,class_reference.foreign_key_association_names)
end #foreign_key_association_names
def assert_associated_foreign_key_name(class_reference,assName)
	if !class_reference.kind_of?(Class) then
		class_reference=class_reference.class
	end #if
	assert_instance_of(Symbol,assName,"associated_foreign_key_name assName=#{assName.inspect}")
	many_to_one_foreign_keys=class_reference.foreign_key_names
#	many_to_one_associations=many_to_one_foreign_keys.collect {|k| k[0..-4]}
	matchingAssNames=many_to_one_foreign_keys.select do |fk|
		assert_instance_of(String,fk)
		ass=fk[0..-4].to_sym
# not class remap		assert_association_many_to_one(class_reference,ass)
		ass==assName
	end #end
	assert_equal(matchingAssNames,[matchingAssNames.first].compact,"assName=#{assName.inspect},matchingAssNames=#{matchingAssNames.inspect},many_to_one_foreign_keys=#{many_to_one_foreign_keys.inspect}")
	assert(class_reference.associated_foreign_key_name(assName))
end #associated_foreign_key_name
def assert_associated_foreign_key(obj,assName)
	assert_instance_of(Symbol,assName,"associated_foreign_key assName=#{assName.inspect}")
	assert_association(obj,assName)
	assert_not_nil(associated_foreign_key_name(obj,assName),"associated_foreign_key_name: obj=#{obj},assName=#{assName})")
	assert obj.method(associated_foreign_key_name(obj,assName).to_sym)
end #associated_foreign_key_records
def assert_association_methods
end #association_methods
# assert that an association named association_reference exists  in class class_reference
def assert_association(class_reference,association_reference, message=nil)
	message=build_message(message, "Class=? association=?", class_reference.inspect, association_reference.inspect)	
	if class_reference.kind_of?(Class) then
		klass=class_reference
	else
		klass=class_reference.class
	end #if
	association_reference=association_reference.to_sym
	assert_not_equal('_id',association_reference.to_s[-3..-1],build_message(message, "association_reference=#{association_reference} should not end in '_id' as it will be confused wth a foreign key."))
	assert_not_equal('_ids',association_reference.to_s[-4..-1],build_message(message, "association_reference=#{association_reference} causes confusion with automatic _ids and _ids= generated for to_many assoiations."))
	if ActiveRecord::Base.instance_methods_from_class(true).include?(association_reference.to_s) then
		raise "# Don't create associations that have the same name (#{association_reference.to_s})as instance methods of ActiveRecord::Base (#{ActiveRecord::Base.instance_methods_from_class.inspect})."
	end #if
	assert_instance_of(Symbol,association_reference,build_message(message, "assert_association"))
	if klass.module_included?(Generic_Table) then
		association_type=klass.association_arity(association_reference)
		assert_not_nil(association_type, message)
		assert_include(association_type,[:to_one,:to_many,:not_an_association],build_message(message, "In assert_association class_reference=#{class_reference.inspect},association_reference=#{association_reference.inspect}"))
	end #if
	#~ explain_assert_respond_to(klass.new,(association_reference.to_s+'=').to_sym)
	#~ assert_public_instance_method(klass.new,association_reference,"association_type=#{association_type}, ")
	assert(klass.is_association?(association_reference),build_message(message, "klass.name=? does not have an association ? but does have associations =?",klass.name,association_reference,klass.association_names))
end #assert_association

def assert_association_to_one(class_reference,assName)
	if !class_reference.kind_of?(Class) then
		class_reference=class_reference.class
	end #if
	assert_instance_of(Symbol,assName,"assert_association_to_one")
	assert_association(class_reference,assName)
	assert(!class_reference.is_association_to_many?(assName),"fail !is_association_to_many?, class_reference.inspect=#{class_reference.inspect},assName=#{assName}, class_reference.similar_methods(assName).inspect=#{class_reference.class.similar_methods(assName).inspect}")
	assert(class_reference.is_association_to_one?(assName),"fail !is_association_to_many?, class_reference.inspect=#{class_reference.inspect},assName=#{assName}, class_reference.similar_methods(assName).inspect=#{class_reference.similar_methods(assName).inspect}")
end #is_association_to_one
def assert_association_to_many(class_reference,assName)
	if !class_reference.kind_of?(Class) then
		class_reference=class_reference.class
	end #if
	assert_instance_of(Symbol,assName,"assert_association_to_many")
	assert_association(class_reference,assName)
	assert(class_reference.is_association_to_many?(assName),"is_association_to_many?(#{class_reference.inspect},#{assName.inspect}) returns false. #{class_reference.similar_methods(assName).inspect}.respond_to?(#{(assName.to_s+'_ids').to_sym}) and class_reference.respond_to?(#{(assName.to_s+'_ids=').to_sym})")
	assert(!class_reference.is_association_to_one?(assName),"fail !is_association_to_one?, class_reference.inspect=#{class_reference.inspect},assName=#{assName}")
end #assert_association_to_many
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
# All records and all foreign keys are not nil
def Base.assert_foreign_keys_not_nil
	all.each do |record|
		record.assert_foreign_keys_not_nil
	end #each
end #assert_foreign_keys_not_nil
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
# All foreign keys of instance are not nil
def assert_foreign_keys_not_nil
	self.class.foreign_key_association_names.each do |fka|
		assert_foreign_key_not_nil(self.class, fka)
	end #each
end #assert_foreign_keys_not_nil
# display possible foreign key values when nil foreign keys values are found
def assert_foreign_key_not_nil(obj, association_name, association_class=obj.association_class(association_name))
	assert_association(obj.class, association_name)
	assert_not_nil(association_class)
	assert_not_nil(association_class)
	possible_foreign_key_values=association_class.all.map do |fkacr|
		fkacr.logical_primary_key_recursive_value.join(',')
	end.uniq #map
	message="Foreign key association #{association_name} is nil.\nShould be of type #{association_class.name}\n"
	message+=possible_foreign_key_values.join("\n")
	message+="\nEdit file #{obj.class.name.tableize}.yml so that foreign key #{association_name}_id has one of the above values."
	assert_not_nil(obj.name_to_association(association_name), message)
end #assert_foreign_key_not_nil
end #Base
end #ActiveRecord

