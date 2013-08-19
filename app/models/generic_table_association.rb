###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/global.rb'
#require_relative '../../app/models/generic_table.rb'
require_relative '../../app/models/stream_method.rb'
module GenericTableAssociation
module ClassMethods
# List names (as Strings) of all foreign keys.
def foreign_key_names
	content_column_names=content_columns.collect {|m| m.name}
	special_columns=column_names-content_column_names
	possible_foreign_keys=special_columns.select { |m| m =~ /_id$/ }
	return possible_foreign_keys
end #foreign_key_names
def is_foreign_key_name?(symbol)
	return foreign_key_names.include?(symbol.to_s) && is_association?(foreign_key_to_association_name(symbol))
end #foreign_key_name
# translate foreign_key into asociation name
# Example: foreign_Key_to_association_name(:fk_id)=='fk' association
def foreign_key_to_association_name(foreign_key)
	foreign_key.to_s.sub(/_id$/,'')
end #foreign_key_to_association_name
# list names of the associations having foreign keys.
def foreign_key_association_names
	foreign_key_names.map {|fk| fk.sub(/_id$/,'')}
end #foreign_key_association_names
def associated_foreign_key_name(association_referenced_by_foreign_key)
	if !is_association?(association_referenced_by_foreign_key.to_s.singularize) then
		raise "Association #{association_referenced_by_foreign_key.to_s.singularize} is not an association of #{self.name}."
	end #if
	many_to_one_foreign_keys=foreign_key_names
	matchingAssNames=many_to_one_foreign_keys.select do |fk|
		ass=fk[0..-4].to_sym
		ass==association_referenced_by_foreign_key.to_s.singularize.to_sym
	end #end
	if matchingAssNames.size==0 then
		raise "Association #{association_referenced_by_foreign_key} does not have a corresponding foreign key in association #{self.name}."
	end #if
	return matchingAssNames.first
end #associated_foreign_key_name
# Does association have me as one of its associations?
def is_matching_association?(association_name)
	 if is_association?(association_name) then
		association_class=association_class(association_name)
		 if association_class.nil? then
			 raise "Association #{association_name.classify} is not a defined constant."
		end #if
		table_symbol=association_class.association_method_symbol(self)
		 if association_class.is_association?(table_symbol) then
			 return true
		elsif association_class.is_association?(association_method_symbol(self.table_name.singularize.to_sym))  then
			return true
		else
			 return false
		end #if
	else
		return false
	end #if
end #matching_association
# return automagically created methods for an association.
def association_methods(association_name)
	return matching_instance_methods(association_name,false)
end #association_methods
def association_patterns(association_name)
	patterns=association_methods(association_name).map do |n| 
		matchData=Regexp.new(association_name.to_s).match(n)
		Regexp.new('^'+matchData.pre_match+'([a-z0-9_]+)'+matchData.post_match+'$')
	end #map
	return Set.new(patterns)
end #association_patterns
def match_association_patterns?(association_name,association_pattern)
	patterns=association_methods(association_name).map do |n| 
		matchData=association_pattern.match(association_pattern)
	end #map
	
	instance_respond_to?(association_name)
end #match_association_patterns
def is_association_patterns?(association_name,association_patterns)
	(association_patterns(association_name)-association_patterns.to_a).empty?&&
	(association_patterns-association_patterns(association_name).to_a).empty?
end #is_association_patterns
def is_association?(association_name)
	# Don’t create associations that have the same name as instance methods of ActiveRecord::Base.
	if ActiveRecord::Base.instance_methods_from_class.include?(association_name.to_s) then
#bad char		raise "# Don’t create associations that have the same name (#{association_name.to_s})as instance methods of ActiveRecord::Base (#{ActiveRecord.instance_methods_from_class})."
	end #if
	if association_name.to_s[-4,4]=='_ids' then # automatically generated
		return false
	elsif self.instance_respond_to?(association_name) and self.instance_respond_to?((association_name.to_s+'=').to_sym)  then
		return true
	else
		return false
	end
end #is_association
def is_association_to_one?(association_name)
	if is_association?(association_name)  and !self.instance_respond_to?((association_name.to_s.singularize+'_ids').to_sym) and !self.instance_respond_to?((association_name.to_s.singularize+'_ids=').to_sym) then
		return true
	else
		return false
	end
end #association_to_one
def is_association_to_many?(association_name)
	if is_association?(association_name)  and self.instance_respond_to?((association_name.to_s.singularize+'_ids').to_sym) and self.instance_respond_to?((association_name.to_s.singularize+'_ids=').to_sym) then
		return true
	else
		return false
	end
end #is_association_to_many
#debug @@Example_polymorphic_patterns=Set.new([/^([a-z0-9_]+)$/, /^set_([a-z0-9_]+)_target$/, /^([a-z0-9_]+)=$/, /^autosave_associated_records_for_([a-z0-9_]+)$/, /^loaded_([a-z0-9_]+)?$/])

def is_polymorphic_association?(association_name)
	return is_association_patterns?(association_name,@@Example_polymorphic_patterns)
end #is_polymorphic_association
def association_names_to_one
	return instance_methods(false).select {|m| is_association_to_one?(m)}
end #association_names_to_one
def association_names_to_many
	return instance_methods(false).select {|m| is_association_to_many?(m)}
end #association_names_to_many
def association_names
	return instance_methods(false).select {|m| is_association_to_one?(m) or is_association_to_many?(m)}
end #association_names
# Returns model name in a canonical form from Class or string, ...
# The return value is canonical in that multiple possible inputs produce the same output.
# always returns a plural, whereas a macro may have a singular argument.
# Generally returns association_table_name.class.name.tableize.to_sym for any object.
# tableize handles some pluralizing, but symbols are unchanged
#routine is meant to handle usual cases in Rails method naming not pathological cases.
# Does not assume an association.
# This flexibility should not be overused. 
# It is intended for finding inverse associations and allowing assertion error messages to suggest what you might have intended.
def name_symbol(model_name)
	if model_name.kind_of?(Class) then
		return model_name.name.tableize.to_sym					
	elsif model_name.kind_of?(String) then
		return model_name.tableize.to_sym						
	elsif model_name.kind_of?(Symbol) then
		return model_name.to_sym
	else # other object
		return model_name.class.name.tableize.to_sym
	end #if
end #name_symbol
# checks whether association symbol exists or if a singular or plural name exists.
def association_method_plurality(association_table_name)
	if self.instance_respond_to?(association_table_name) then
		return association_table_name.to_sym
	elsif self.instance_respond_to?(association_table_name.to_s.singularize) then
		return association_table_name.to_s.singularize.to_sym
	elsif self.instance_respond_to?(association_table_name.to_s.pluralize) then
		return association_table_name.to_s.pluralize.to_sym
	else # don't know what to do; most likely cure
		return association_table_name.to_s.pluralize.to_sym
	end #if
end #association_method_plurality
# For convenience handles both type and plurality.
def association_method_symbol(association_table_name)
	return association_method_plurality(name_symbol(association_table_name))
end #association_method_symbol
# return association's default_class name
# can be used as a boolean test
def association_default_class_name?(association_name)
	default_association_class_name=association_name.to_s.classify
	if eval("defined? #{default_association_class_name}") then
		return default_association_class_name
	else
		return nil # not default class name
	end #if
end #association_default_class_name
# return class when passed a symbol reference
def association_class(association_name)
	 if !is_association?(association_method_symbol(association_name)) then
		raise "#{association_method_symbol(association_name)} is not an association of #{self.name}."
	elsif is_polymorphic_association?(association_name) then
		raise "Polymorphic associations #{association_method_symbol(association_name)} of #{self.name} do not have a single class.. Need instance not class method "
	else
		default_class_defined=association_default_class_name?(association_name)
		if default_class_defined then
			return Generic_Table.class_of_name(association_default_class_name?(association_name))
		else
			all_parents=all
			all_association_classes=all_parents.map do |bc|
				bc.association_class(association_name)
			end.flatten.uniq #map
			if all_association_classes.size==1 then
				return all_association_classes[0] # remove Array
			else
				return all_association_classes # polymorphic? impossible?
			end #if
		end #if
	end #if
end #Base_association_class
# returns :to_one, :to_many, or :not_an_association
def association_arity(association_name)
	if is_association_to_one?(association_name) then
		return :to_one
	elsif is_association_to_many?(association_name) then
		return :to_many
	else 
		return :not_an_association
	end #if
end #association_arity
end #module ClassMethods
# transform association name into association records for instance
def name_to_association(association_name)
	method(association_name).call
end #name_to_association
# translate foreign_key into asociation
# Example: foreign_Key_to_association(:fk_id)==fk association
def foreign_key_to_association(foreign_key)
	name_to_association(self.class.foreign_key_to_association_name(foreign_key))
end #foreign_Key_to_association
def foreign_key_value(association_name)
	return self[association_name.to_s+'_id']
end #foreign_key_value
# find records pointed to by foreign key.
def associated_foreign_key_records(association_with_foreign_key)
	class_with_foreign_key=self.class.association_class(association_with_foreign_key)
	foreign_key_symbol=class_with_foreign_key.associated_foreign_key_name(self.class.name.tableize)
	associated_records=class_with_foreign_key.where(foreign_key_symbol => self[:id])

	return associated_records
end #associated_foreign_key_records
def association_class(association_name)
	 if !self.kind_of?(ActiveRecord::Base) then
		raise "#{self.class.name} is not an ActiveRecord::Base."
	 elsif !self.class.is_association?(self.class.association_method_symbol(association_name)) then
		raise "association_name=#{association_name.inspect}, #{self.class.association_method_symbol(association_name)} is not an association of #{self.class.name}."
	else
		association=name_to_association(association_name)
		if association.instance_of?(Array) then
			classes=association.enumerate(:map){|r| r.class}.uniq
			if classes.size==1 then
				return classes[0] # remove Array
			else
				return classes # polymorphic? impossible?
			end #if
		else
			return association.enumerate(:map){|r| r.class}
		end #if
	end #if
end #association_class
def foreign_key_points_to_me?(ar_from_fixture,association_name)
	associated_records=assert_call_result(ar_from_fixture,association_name)
	if associated_records.instance_of?(Array) then
		associated_records.each do |ar|
			fkAssName=ar_from_fixture.class.name.tableize.singularize
			fk=ar.class.associated_foreign_key_name(fkAssName.to_s.to_sym)
			@associated_foreign_key_id=ar[fk]
		end #each
	else # single record
			ar.class.associated_foreign_key_name(associated_records,association_name).each do |fk|
				assert_equal(ar_from_fixture.id,associated_foreign_key_id(associated_records,fk.to_sym),"assert_foreign_key_points_to_me: associated_records=#{associated_records.inspect},ar_from_fixture=#{ar_from_fixture.inspect},association_name=#{association_name}")
			end #each
	end #if
end #foreign_key_points_to_me
# logical key with each foeign key replaced by logical key value pointed to
def logical_primary_key_recursive_value(delimiter=',')
	if self.class.sequential_id? then
		return logical_primary_key_value
	else
		self.class.logical_primary_key.map do |e| 
			if self.class.is_foreign_key_name?(e) then
				association=foreign_key_to_association(e)
				if association.nil? then
					nil
				else
					association.logical_primary_key_recursive_value 
				end #if
			else
				self[e]
			end #if
		end #map
	end #if
end #logical_primary_key_recursive_value
def logical_primary_key_value(delimiter=',')
	if self.class.sequential_id? then
		if self.respond_to?(:logical_primary_key) then # still sequential, not requred, default
			return self[:created_at] # better sequential key
		else
			return id # logical primary key
		end
	else
		if self.class.logical_primary_key.is_a?(Array) then
			return self.class.logical_primary_key.map {|k| self[k]}.join(delimiter)
		else #not array
			return self[self.class.logical_primary_key]
		end #if
	end #if
end #logical_primary_key_value
# Display attribute or method value from association even if association is nil
def association_state(association_name)
	case self.class.association_arity(association_name)
	when :to_one
		foreign_key_value=foreign_key_value(association_name)
		if foreign_key_value.nil? then # foreign key uninitialized
			return "Foreign key #{association_name.to_s}_id defined as attribute but has nil value."
		#~ elsif foreign_key_value.empty? then # foreign key uninitialized
			#~ return "Foreign key #{association_name.to_s}_id defined as attribute but has empty value."
		else
			ass=send(association_name)
			if ass.nil? then
				return "Foreign key #{association_name.to_s}_id has value #{foreign_key_value.inspect} but the association returns nil."
			else
				return "Foreign key #{association_name.to_s}_id has value #{foreign_key_value.inspect},#{ass.inspect} and returns type #{ass.class.name}."
			end
		end
	when :to_many
		ass=send(association_name)
		associations_foreign_key_name=(self.class.name.tableize.singularize+'_id').to_sym
		if ass.nil? then
			return "Association #{association_name}'s foreign key #{associations_foreign_key_name} has value #{ass[self.class.name.to_s+'_id']} but the association returns nil."
		elsif ass.empty? then
			ret= "Association #{association_name} with foreign key #{associations_foreign_key_name} is empty; "
			case self.class.association_class(association_name).association_macro_type(self.class.name.tableize.singularize)
			when :has_many
				return ret+"but has many."
			when :belongs_to
				return ret+"but belongs_to."
			when :neither_has_many_nor_belongs_to
				return ret+"because neither_has_many_nor_belongs_to."
			else
				return "New return value from #{self.class.name}.association_macro_type(#{association_name})=#{self.class.association_macro_type(association_name)}."
			end #case
		else
			associations_foreign_key_values=ass.map { |a| a.send(associations_foreign_key_name) }.uniq.join(',')
			return "Association #{association_name}'s foreign key #{associations_foreign_key_name} has value #{associations_foreign_key_values},#{ass.inspect} and returns type #{ass.class.name}."
		end
		
	when :not_generic_table
		return "#{self.class.name} does not recognize #{association_name} as a generic table."
	when:not_an_association
		return "#{self.class.name} does not recognize #{association_name} as association."
	else
		return "New return value from #{self.class.name}.association_arity(#{association_name})=#{self.class.association_arity(association_name)}."
	end #if
end #association_state
def association_has_data(association_name)
	return association_state(association_name)[/ and returns type /,0]
end #def
def associated_to_s(association_name,method,*args)
	if self[association_name.to_s+'_id'].nil? then # foreign key uninitialized
		return ''
	else
		ass=send(association_name)
		if ass.nil? then
			return ''
		else
			return ass.send(method.to_sym,*args).to_s
		end
	end
end #associated_to_s

module Examples
First_stream_method=StreamMethod.first
end #Examples
include Examples
require_relative '../../test/assertions/default_assertions.rb'
module Assertions
include DefaultAssertions
module ClassMethods
include DefaultAssertions::ClassMethods
# All records and all foreign keys are not nil
def assert_foreign_keys_not_nil
	all.each do |record|
		record.assert_foreign_keys_not_nil
	end #each
end #assert_foreign_keys_not_nil
def assert_pre_conditions
#	fail "end of class assert_pre_conditions "
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
def assert_invariant
#	fail "end of instance assert_pre_conditions"
end #assert_invariant
end #ClassMethods
def assert_foreign_key_name(class_reference, foreign_key_name)
	if !class_reference.kind_of?(Class) then
		class_reference=class_reference.class
	end #if
	if !foreign_key_name.kind_of?(String) then
		foreign_key_name=foreign_key_name.to_s
	end #if
	assert_block("foreign_key_name=#{foreign_key_name} is not a foreign key of class_reference=#{class_reference.inspect}"){class_reference.foreign_key_names.include?(foreign_key_name)}
end #assert_foreign_key_name
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
def assert_foreign_key_association_names(class_reference,association_reference)
	assert_include(class_reference.foreign_key_association_names, association_reference.to_s)
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
		raise "Don't create associations that have the same name (#{association_reference.to_s})as instance methods of ActiveRecord::Base (#{ActiveRecord::Base.instance_methods_from_class.inspect})."
	end #if
	assert_instance_of(Symbol,association_reference,build_message(message, "assert_association"))
	if klass.module_included?(Generic_Table) then
		association_type=klass.association_arity(association_reference)
		assert_not_nil(association_type, message)
		assert_include([:to_one,:to_many,:not_an_association], association_type, build_message(message, "In assert_association class_reference=#{class_reference.inspect},association_reference=#{association_reference.inspect}"))
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
# true at all times
def assert_invariant
end #assert_invariant
# true after creating an object from scratch
def assert_pre_conditions
#	fail "end of instance assert_pre_conditions"
end #assert_pre_conditions
# conditions after all ActiveRecord reading and initialization 
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
end # GenericTableAssociation
