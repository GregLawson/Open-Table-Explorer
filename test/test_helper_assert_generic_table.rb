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

# assertions testing single global (Object) methods
# assertions testing single generic_table methods
def all_foreign_key_associations(&block)
	Generic_Table.rails_MVC_classes.each do |class_with_foreign_key|
		class_with_foreign_key.foreign_key_association_names.each do |foreign_key_association_name|
			block.call(class_with_foreign_key, foreign_key_association_name)
		end #each
	end #each
end #all_associations
def association_refs(class_reference=@@example_class_reference, association_reference=@@example_association_reference, &block)
	if class_reference.kind_of?(Class) then
		klass=class_reference
	else
		klass=class_reference.class
	end #if
	association_reference=association_reference.to_sym
	assert_instance_of(Symbol,association_reference,"In association_refs, association_reference=#{association_reference} must be a Symbol.")
	assert_instance_of(Class,class_reference,"In test_is_association, class_reference=#{class_reference} must be a Class.")
#	assert_kind_of(ActiveRecord::Base,class_reference)
	assert_ActiveRecord_table(class_reference.name)
	block.call(class_reference, association_reference)
end #association_refs
def assert_foreign_key_name(class_reference, foreign_key_name)
	if !class_reference.kind_of?(Class) then
		class_reference=class_reference.class
	end #if
	if !foreign_key_name.kind_of?(String) then
		foreign_key_name=foreign_key_name.to_s
	end #if
	assert_block("foreign_key_name=#{foreign_key_name} is not a foreign key of class_reference=#{class_reference.inspect}"){class_reference.foreign_key_names.include?(foreign_key_name)}
end #foreign_key_names
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
end #def
def assert_associated_foreign_key(obj,assName)
	assert_instance_of(Symbol,assName,"associated_foreign_key assName=#{assName.inspect}")
	assert_association(obj,assName)
	assert_not_nil(associated_foreign_key_name(obj,assName),"associated_foreign_key_name: obj=#{obj},assName=#{assName})")
	assert obj.method(associated_foreign_key_name(obj,assName).to_sym)
end #def

# assert that an association named association_reference exists  in class class_reference as well as an association named class_reference.name  exists  in class association_reference
def assert_matching_association(klass,association_name)
	assert(klass.is_matching_association?(association_name))
end #matching_association
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
		raise "# Don’t create associations that have the same name (#{association_reference.to_s})as instance methods of ActiveRecord::Base (#{ActiveRecord::Base.instance_methods_from_class.inspect})."
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
end #def

def assert_association_to_one(class_reference,assName)
	if !class_reference.kind_of?(Class) then
		class_reference=class_reference.class
	end #if
	assert_instance_of(Symbol,assName,"assert_association_to_one")
	assert_association(class_reference,assName)
	assert(!class_reference.is_association_to_many?(assName),"fail !is_association_to_many?, class_reference.inspect=#{class_reference.inspect},assName=#{assName}, class_reference.similar_methods(assName).inspect=#{class_reference.class.similar_methods(assName).inspect}")
	assert(class_reference.is_association_to_one?(assName),"fail !is_association_to_many?, class_reference.inspect=#{class_reference.inspect},assName=#{assName}, class_reference.similar_methods(assName).inspect=#{class_reference.similar_methods(assName).inspect}")
end #association_to_one
def assert_association_to_many(class_reference,assName)
	if !class_reference.kind_of?(Class) then
		class_reference=class_reference.class
	end #if
	assert_instance_of(Symbol,assName,"assert_association_to_many")
	assert_association(class_reference,assName)
	assert(class_reference.is_association_to_many?(assName),"is_association_to_many?(#{class_reference.inspect},#{assName.inspect}) returns false. #{class_reference.similar_methods(assName).inspect}.respond_to?(#{(assName.to_s+'_ids').to_sym}) and class_reference.respond_to?(#{(assName.to_s+'_ids=').to_sym})")
	assert(!class_reference.is_association_to_one?(assName),"fail !is_association_to_one?, class_reference.inspect=#{class_reference.inspect},assName=#{assName}")
end #association_to_many
def assert_has_many_association(class_reference, association_name)
	assert(class_reference.association_grep('has_many',association_name))
end #def
def assert_belongs_to_association(class_reference, association_name)
	assert(class_reference.association_grep('belongs_to',association_name))
end #def
def assert_belongs_to(table_name1,table_name2)
	model_class=Generic_Table.eval_constant(table_name1.classify)
	assert_not_nil(model_class,"model_class #{table_name1.classify} is not a defined constant.")
	if  model_class.is_association_to_one?(table_name2) then
		assert_include(table_name2,model_class.foreign_key_names.map {|fk| fk.sub(/_id$/,'')})
	end #if
end #def
def assert_active_record_method(method_name)
	assert(ActiveRecord::Base.is_active_record_method?(method_name))
end #def
def assert_not_active_record_method(method_name)
	assert(!ActiveRecord::Base.is_active_record_method?(method_name))
end #def
#
# assertions not directly testing single generic_table methods
#
def assert_foreign_key_points_to_me(ar_from_fixture,assName)
	assert_association(ar_from_fixture.class,assName)
	associated_records=ar_from_fixture.associated_foreign_key_records(assName)
	assert_not_empty(associated_records,"assert_foreign_key_points_to_me ar_from_fixture.inspect=#{ar_from_fixture.inspect},assName=#{assName} Check if id is specified in #{assName.to_sym}.yml file.")
end #def
def assert_association_one_to_one(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"assert_association_one_to_one")
	assert_association_to_one(ar_from_fixture,assName)
end #def
def assert_association_one_to_many(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"assert_association_one_to_many")
	assert_association_to_many(ar_from_fixture,assName)
end #is_association_to_many
def assert_association_many_to_one(ar_from_fixture,assName)
	assert_instance_of(Symbol,assName,"assert_association_many_to_one")
	assert_association_to_one(ar_from_fixture,assName)
end #def
def assert_associations(ass1,ass2,message=nil)
	message=build_message(message, "ass1=? ass2=?", ass1.inspect, ass2.inspect)	
	class1=ass1.to_s.classify.constantize # must succeed
	association_symbol2=class1.association_method_symbol(ass2)
	assert_association(class1,association_symbol2, message)
	class2=association_symbol2.to_s.classify.constantize
	assert_kind_of(Class,class1.association_class(ass2), message)
	assert_kind_of(Symbol,class2.association_method_symbol(ass1), message)
	if !class1.is_polymorphic_association?(ass2) then
		assert_association(class1.association_class(ass2),class2.association_method_symbol(ass1), message)
	end #if
end #def
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
end #def
def assert_table_exists(table_name)
	message="#{'table_name'.titleize} #{table_name} does not exist as a database table."
	assert_block(message){Generic_Table.table_exists?(table_name)}
end #def
def assert_table(table_name)
	message="#{'table_name'.titleize} #{table_name} does not exist and may be misspelled."
	assert_block(message){Generic_Table.is_table?(table_name)}
end #def
def assert_ActiveRecord_table(model_class_name)
	assert_table(model_class_name.tableize)
	message="#{'model_class_name'.titleize} #{model_class_name} is not an ActiveRecord table."
	assert_block(message){Generic_Table.is_ActiveRecord_table?(model_class_name)}
end #def
def assert_generic_table(model_class_name)
	assert_no_match(/_ids$/,model_class_name,"Table name should not end in _ids to avoid confusion with to many associations.")
	assert_ActiveRecord_table(model_class_name)
	message="#{'model_class_name'.titleize} #{model_class_name} is not a Generic Table."
	assert_block(message){Generic_Table.is_generic_table?(model_class_name)}
end #def
def assert_matching_association(table_reference,association_name)
	table_class=ActiveRecord::Base.class_of_name(table_reference)
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
end #def
def assert_has_associations(model_class,message='')
	message=build_message(message, "? has no associations. #{model_class.name}.rb is missing has_* or belongs_to macros.", model_class.canonicalName)   
	assert_block(message){!model_class.association_names.empty?}	
end #def
def assert_module_included(klass,moduleName)
#The assertion upon which all other assertions are based. Passes if the block yields true.
  assert_block "Module #{moduleName} not included in #{klass.canonicalName} context.Modules actually included=#{klass.ancestors.inspect}. klass.module_included?(moduleName)=#{klass.module_included?(moduleName)}" do
    klass.module_included?(moduleName)
  end

end #def

