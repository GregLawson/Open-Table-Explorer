require 'test_helper'
# executed in alphabetical orer? Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
require 'test/test_helper_test_tables.rb'
class GenericTableTest < ActiveSupport::TestCase
test "foreign_key_names" do
	content_column_names=StreamPatternArgument.content_columns.collect {|m| m.name}
	assert_include('stream_pattern_id',StreamPatternArgument.column_names)
	special_columns=StreamPatternArgument.column_names-content_column_names
	assert_include('stream_pattern_id',special_columns)
	assert_equal(['stream_pattern_id','parameter_id'],StreamPatternArgument.foreign_key_names)
	assert_not_empty(StreamPatternArgument.foreign_key_names)
	possible_foreign_keys=StreamPatternArgument.foreign_key_names
	assert_not_empty(possible_foreign_keys)
	assert_include('stream_pattern_id',possible_foreign_keys)
end #foreign_key_names
test "foreign_key_association_names" do
	assert_include('stream_pattern_id',StreamPatternArgument.foreign_key_names)
	assert_include('stream_pattern',StreamPatternArgument.foreign_key_names.map {|fk| fk.sub(/_id$/,'')})
end #foreign_key_association_names

test "associated_foreign_key_name" do
	many_to_one_foreign_keys=StreamPatternArgument.foreign_key_names
	assert_not_empty(many_to_one_foreign_keys)
	matchingAssNames=many_to_one_foreign_keys.select do |fk|
		ass=fk[0..-4].to_sym
		ass==:stream_pattern
	end #end
	assert_equal(1, matchingAssNames.size)
	assert_equal(@@FOREIGN_KEY_ASSOCIATION_SYMBOL.to_s+'_id',@@CLASS_WITH_FOREIGN_KEY.associated_foreign_key_name(@@FOREIGN_KEY_ASSOCIATION_SYMBOL))
end #associated_foreign_key_name
test "associated_foreign_key_records" do
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
test "is_matching_association?" do
	 assert_association(@@CLASS_WITH_FOREIGN_KEY,@@FOREIGN_KEY_ASSOCIATION_SYMBOL)
#	 association_class=@@CLASS_WITH_FOREIGN_KEY.association_class(@@FOREIGN_KEY_ASSOCIATION_SYMBOL)
	 association_class=@@FOREIGN_KEY_ASSOCIATION_CLASS.association_class(@@TABLE_NAME_WITH_FOREIGN_KEY)
	assert_equal(association_class,@@CLASS_WITH_FOREIGN_KEY)
	assert_not_nil(association_class)
	assert_equal(@@FOREIGN_KEY_ASSOCIATION_SYMBOL,association_class.association_method_symbol(@@FOREIGN_KEY_ASSOCIATION_SYMBOL))
	assert(@@CLASS_WITH_FOREIGN_KEY.is_matching_association?(@@FOREIGN_KEY_ASSOCIATION_SYMBOL))
end #is_matching_association

test 'association_methods' do
	class_reference=@@FOREIGN_KEY_ASSOCIATION_CLASS
	association_reference=@@TABLE_NAME_WITH_FOREIGN_KEY

	assert_equal_sets(["stream_pattern_arguments=", "validate_associated_records_for_stream_pattern_arguments","autosave_associated_records_for_stream_pattern_arguments", "stream_pattern_arguments"],class_reference.association_methods(association_reference))
end #association_methods
@@fk_association_patterns=Set.new([/^autosave_associated_records_for_([a-z0-9_]+)$/, /^([a-z0-9_]+)=$/, /^validate_associated_records_for_([a-z0-9_]+)$/, /^([a-z0-9_]+)$/])
test 'association_patterns' do
	class_reference=@@FOREIGN_KEY_ASSOCIATION_CLASS
	association_reference=@@TABLE_NAME_WITH_FOREIGN_KEY.to_sym
	matchData=Regexp.new(association_reference.to_s).match(association_reference.to_s)
	assert_equal("^([a-z0-9_]+)$",'^'+matchData.pre_match+'([a-z0-9_]+)'+matchData.post_match+'$')
	assert_equal_sets(@@fk_association_patterns,class_reference.association_patterns(association_reference))
end #association_patterns
test 'match_association_patterns' do
	class_reference=@@FOREIGN_KEY_ASSOCIATION_CLASS
	association_name=@@TABLE_NAME_WITH_FOREIGN_KEY
#	assert(class_reference.instance_respond_to?(association_name))
	assert(class_reference.match_association_patterns?(association_name,association_name))
end #match_association_patterns
test 'is_association_patterns' do
	class_reference=@@FOREIGN_KEY_ASSOCIATION_CLASS
	association_reference=@@TABLE_NAME_WITH_FOREIGN_KEY
	assert_equal_sets(@@fk_association_patterns,class_reference.association_patterns(association_reference))
	assert_empty(@@fk_association_patterns-class_reference.association_patterns(association_reference))
	assert_empty(class_reference.association_patterns(association_reference)-@@fk_association_patterns)
	assert(class_reference.is_association_patterns?(association_reference,@@fk_association_patterns))
end #is_association_patterns
test "is_association" do
	class_reference=StreamMethodArgument
	association_reference=:parameter
	if class_reference.kind_of?(Class) then
		klass=class_reference
	else
		klass=class_reference.class
	end #if
	association_reference=association_reference.to_sym
	assert_instance_of(Symbol,association_reference,"In assert_association, association_reference=#{association_reference} must be a Symbol.")
#  For instance, attributes and connection would be bad choices for association names.
	assert_include('attributes',ActiveRecord::Base.instance_methods_from_class, "# Don’t create associations that have the same name (#{association_reference})as instance methods of ActiveRecord::Base (#{ActiveRecord.instance_methods_from_class}).")
	assert_include('connection',ActiveRecord::Base.instance_methods_from_class, "# Don’t create associations that have the same name (#{association_reference})as instance methods of ActiveRecord::Base (#{ActiveRecord.instance_methods_from_class}).")
	assert_instance_of(Symbol,association_reference,"assert_association")
	assert_not_include(association_reference.to_s,ActiveRecord::Base.instance_methods_from_class, "# Don’t create associations that have the same name (#{association_reference})as instance methods of ActiveRecord::Base (#{ActiveRecord.instance_methods_from_class}).")
	if klass.module_included?(Generic_Table) then
		association_type=klass.association_to_type(association_reference)
		assert_not_nil(association_type)
		assert_include(association_type,[:to_one,:to_many])
	end #if
	#~ explain_assert_respond_to(klass.new,(association_reference.to_s+'=').to_sym)
	#~ assert_public_instance_method(klass.new,association_reference.to_s,"association_type=#{association_type.to_s}, ")
	assert(klass.is_association?(association_reference),"fail is_association?, klass.inspect=#{klass.inspect},association_reference=#{association_reference}")
end #is_association
test 'is_association_to_one' do
	class_reference=StreamMethodArgument
	association_reference=:parameter
	explain_assert_respond_to(class_reference.new,(association_reference.to_s.singularize+'_id').to_sym)
	explain_assert_respond_to(class_reference.new,(association_reference.to_s.singularize+'_id=').to_sym)
	assert(class_reference.is_association?(association_reference),"fail is_association?, class_reference.inspect=#{class_reference.inspect},association_reference=#{association_reference}")
	assert(class_reference.is_association_to_one?(association_reference),"fail is_association?, class_reference.inspect=#{class_reference.inspect},association_reference=#{association_reference}")
end #is_association_to_one
test 'is_association_to_many' do
	class_reference=@@FOREIGN_KEY_ASSOCIATION_CLASS
	association_reference=@@TABLE_NAME_WITH_FOREIGN_KEY
	explain_assert_respond_to(class_reference.new,(association_reference.to_s.singularize+'_ids').to_sym)
	explain_assert_respond_to(class_reference.new,(association_reference.to_s.singularize+'_ids=').to_sym)
	assert(class_reference.is_association?(association_reference),"fail in is_association_to_many?, class_reference.inspect=#{class_reference.inspect},association_reference=#{association_reference}")
	assert(class_reference.is_association_to_many?(association_reference),"fail is_association?, class_reference.inspect=#{class_reference.inspect},association_reference=#{association_reference}")
end #is_association_to_many
test 'is_polymorphic_association' do
	@possible_nonpolymorphic_methods=Set.new(["create_stream_pattern", "stream_pattern=", "build_stream_pattern", "set_stream_pattern_target", "stream_pattern", "loaded_stream_pattern?", "autosave_associated_records_for_stream_pattern"])
	assert_equal(@possible_nonpolymorphic_methods,Set.new(StreamPatternArgument.matching_instance_methods(:stream_pattern.to_s)))
	@example_nonpolymorphic_patterns=Set.new([/^build_([a-z0-9_]+)$/, /^([a-z0-9_]+)=$/,/^autosave_associated_records_for_([a-z0-9_]+)$/, /^set_([a-z0-9_]+)_target$/, /^loaded_([a-z0-9_]+)?$/, /^create_([a-z0-9_]+)$/, /^([a-z0-9_]+)$/])
	assert_equal_sets(@example_nonpolymorphic_patterns,Set.new(StreamPatternArgument.association_patterns(:stream_pattern.to_s)))

	class_reference=Node
	association_name=:branch
	@possible_polymorphic_methods=Set.new(["autosave_associated_records_for_branch","loaded_branch?", "set_branch_target", "branch","branch="])
	assert_equal_sets(@possible_polymorphic_methods,Set.new(class_reference.matching_instance_methods(association_name.to_s)))

	@example_polymorphic_patterns=Set.new([/^([a-z0-9_]+)$/, /^set_([a-z0-9_]+)_target$/, /^([a-z0-9_]+)=$/, /^autosave_associated_records_for_([a-z0-9_]+)$/, /^loaded_([a-z0-9_]+)?$/])
	assert_equal_sets(@example_polymorphic_patterns,Set.new(class_reference.association_patterns(association_name.to_s)))
	assert_equal_sets(@example_polymorphic_patterns,Set.new(StreamMethodArgument.association_patterns(:parameter.to_s)))

	@possible_polymorphic_patterns2=Set.new(["", "autosave_associated_records_for_", "validate_associated_records_for_","="])
	@common_patterns=@example_nonpolymorphic_patterns & @example_polymorphic_patterns
	
#	assert(@example_polymorphic_patterns.all? { |a| class_reference.instance_respond_to?(a)})

#	assert(@example_polymorphic_patterns.all? { |a| class_reference.instance_respond_to?(a)})

	assert(class_reference.is_polymorphic_association?(association_name))
end #is_polymorphic_association
test 'association_names_to_many' do
	class_reference=StreamMethodArgument
	assert(class_reference.instance_methods(false).select {|m| class_reference.is_association_to_many?(m)})
end #test
test 'association_names' do
	class_reference=StreamMethodArgument
	assert_not_empty(class_reference.instance_methods(false).select {|m| class_reference.is_association?(m)})
	assert_not_include('bug_ids', TestRun.association_names_to_one)
	assert_equal([],TestRun.association_names_to_one)
	assert_not_include('bug_ids', TestRun.association_names_to_many)
	assert_equal(['bugs'],TestRun.association_names_to_many)
	assert_not_include('bug_ids', TestRun.association_names)
	assert_equal(['bugs'],TestRun.association_names)
end #test
test "has_many_association" do
	assert_equal('app/models/stream_method.rb',StreamMethod.model_file_name)
	assert(StreamMethod.has_many_association?(:stream_method_arguments),StreamMethod.association_grep('has_many',:stream_method_arguments))
	assert(StreamMethod.has_many_association?('stream_method_arguments'),StreamMethod.association_grep('has_many','stream_method_arguments'))
	ar_from_fixture=table_specs(:ifconfig)
	assName=:acquisition_stream_specs

	if ar_from_fixture.respond_to?(assName) then
		assert_public_instance_method(ar_from_fixture,assName)		
	else
		assert_public_instance_method(ar_from_fixture,assName.to_s.singularize.to_sym)
	end #if

	ASSNAME=ar_from_fixture.class.association_method_symbol(assName)

	assert_public_instance_method(ar_from_fixture,ASSNAME)

#	assert_equal_sets(["has_one", "has_many", "has_and_belongs_to_many"],Frequency.new.matching_instance_methods(/^has_/))
end #test
test "association_method_plurality" do
	assert_equal(:full_associated_models,TestTable.association_method_plurality(:full_associated_models))
	assert_equal(:full_associated_models,TestTable.association_method_plurality(:full_associated_model))
	assert_equal(:full_associated_models,TestTable.association_method_plurality(:full_associated_model))
	assert_equal(:stream_pattern,StreamPatternArgument.association_method_plurality(:stream_patterns))
	assert_equal(:stream_pattern,StreamPatternArgument.association_method_plurality(:stream_pattern))
	assert_equal(:stream_pattern,StreamPatternArgument.association_method_plurality(:stream_patterns))
end #test
test "association_class" do
	 assert_association(@@CLASS_WITH_FOREIGN_KEY,@@FOREIGN_KEY_ASSOCIATION_SYMBOL)
	assert_equal(@@FOREIGN_KEY_ASSOCIATION_CLASS,@@CLASS_WITH_FOREIGN_KEY.class_of_name(@@FOREIGN_KEY_ASSOCIATION_SYMBOL))
end #test
test "association_method_symbol" do
	assert_equal(:full_associated_models,TestTable.association_method_symbol(:full_associated_models))
	assert_equal(:full_associated_models,TestTable.association_method_symbol(:full_associated_model))
	
	assert_public_instance_method(StreamPatternArgument.new,:stream_pattern)
	assert_equal(:stream_pattern,StreamPatternArgument.association_method_symbol(:stream_pattern))
	assert_equal(:stream_pattern,StreamPatternArgument.association_method_symbol(:stream_patterns))
	 association_class=@@FOREIGN_KEY_ASSOCIATION_CLASS.association_class(@@TABLE_NAME_WITH_FOREIGN_KEY)
	assert_equal(association_class,@@CLASS_WITH_FOREIGN_KEY)
	assert_equal(@@FOREIGN_KEY_ASSOCIATION_SYMBOL,association_class.association_method_symbol(@@FOREIGN_KEY_ASSOCIATION_SYMBOL))
end #test

def foreign_key_points_to_me?(ar_from_fixture,assName)
	associated_records=testCallResult(ar_from_fixture,assName)
	if associated_records.instance_of?(Array) then
		associated_records.each do |ar|
			fkAssName=ar_from_fixture.class.name.tableize.singularize
			fk=ar.class.associated_foreign_key_name(fkAssName.to_s.to_sym)
			@associated_foreign_key_id=ar[fk]
		end #each
	else # single record
			ar.class.associated_foreign_key_name(associated_records,assName).each do |fk|
				assert_equal(ar_from_fixture.id,associated_foreign_key_id(associated_records,fk.to_sym),"assert_foreign_key_points_to_me: associated_records=#{associated_records.inspect},ar_from_fixture=#{ar_from_fixture.inspect},assName=#{assName}")
			end #each
	end #if
end #def
test 'association_to_type' do
	class_reference=StreamMethodArgument
	association_reference=:parameter
	assert_association_to_one(class_reference,association_reference)
end #association_to_type
test 'is_active_record_method' do
	association_reference=:parameter
	assert(ActiveRecord::Base.instance_methods_from_class.include?(:connection.to_s))
	assert(!ActiveRecord::Base.instance_methods_from_class.include?(:parameter.to_s))
	assert(!TestTable.is_active_record_method?(:parameter))
	assert(TestTable.is_active_record_method?(:connection))
end #is_active_record_method
test 'sequential_id' do
end # def
test 'logical_primary_key_value' do
end #def
test 'Inter-model associations' do
#	puts "model_classes=#{model_classes.inspect}"
	Generic_Table.rails_MVC_classes.each do |class_with_foreign_key|
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
						puts "#{foreign_key_association_name} is not a generic table in #{Generic_Table.rails_MVC_classes.map {|c| c.name}.inspect}."
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
def test_aaa
	acquisition_stream_spec=acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym)

	assert(AcquisitionStreamSpec.instance_methods(false).include?('acquisition_interface'))
	assert(AcquisitionStreamSpec.instance_methods(false).include?('table_spec'))
	assert_public_instance_method(acquisition_stream_spec,:acquisition_interface)
	assert_raise(Test::Unit::AssertionFailedError) {assert_public_instance_method(acquisition_stream_spec,:acquisition_interfaces) }
	assert_raise(Test::Unit::AssertionFailedError) { assert_public_instance_method(acquisition_stream_spec,:cabbage) }
	assert_equal(Fixtures::identify(:HTTP),acquisition_interfaces(:HTTP).id)
	assert_equal(Fixtures::identify(:HTTP),acquisition_stream_spec.acquisition_interface_id)
	assert_equal(acquisition_stream_spec.acquisition_interface_id,acquisition_interfaces(:HTTP).id)
	assert_equal(acquisition_stream_spec.scheme,acquisition_interfaces(:HTTP).scheme)
	assert_equal(acquisition_stream_spec.scheme,acquisition_stream_spec.acquisition_interface.scheme)
	testCall(acquisition_stream_spec,:acquisition_interface)
	assert_association(acquisition_stream_spec,:acquisition_interface)
#	assert_equal('',acquisitions(:one).associated_to_s(:acquisition_stream_spec,:url))
end
test "Generic Table" do
	assert(GenericTableAssociatedModel.module_included?(Generic_Table))
	assert_module_included(GenericTableAssociatedModel,Generic_Table)
	
	assert_kind_of(Class,Acquisition)
	assert_kind_of(Class,ActiveRecord::Base)
	assert_kind_of(ActiveRecord::Base,Acquisition.new)
	assert(Acquisition.new.kind_of?(ActiveRecord::Base))
	model_class=eval("Acquisition")
	assert(model_class.new.kind_of?(ActiveRecord::Base))
	assert(model_class.module_included?(Generic_Table))
	model_class=eval("acquisitions".classify)
	assert(model_class.module_included?(Generic_Table))

	
	assert(Generic_Table.table_exists?("acquisitions".tableize))
	assert(Generic_Table.table_exists?("acquisitions"))
	assert_table("acquisitions")
	assert_table_exists("acquisitions")
	assert(model_class.new.kind_of?(ActiveRecord::Base))
	assert(Generic_Table.is_ActiveRecord_table?("Acquisition"))
	assert_ActiveRecord_table("Acquisition")
	assert_generic_table("Acquisition")
	assert(Generic_Table.is_generic_table?("Acquisition"))
	assert(Generic_Table.is_generic_table?("acquisitions".classify))
	assert(Generic_Table.is_generic_table?("acquisitions"))
	assert(Generic_Table.is_generic_table?(Acquisition.name))
	assert(Generic_Table.is_generic_table?("frequency"))
	assert(Generic_Table.is_generic_table?("acquisition_stream_specs"))
	assert(!Generic_Table.is_generic_table?("fake_belongs_to"))
	assert(!Generic_Table.is_generic_table?("fake_has_and_belongs_to_many"))
	assert(!Generic_Table.is_generic_table?("fake_has_one"))
	assert(!Generic_Table.is_generic_table?("fake_has_many"))

	
	assert(Generic_Table.rails_MVC_class?(:stream_pattern))
	assert(Generic_Table.rails_MVC_class?(:stream_pattern))
	assert_include('StreamMethod',Generic_Table.rails_MVC_classes.map {|c| c.name})
	assert(Generic_Table.rails_MVC_classes.map {|c| c.name}.include?('StreamMethod'))
	assert(Generic_Table.rails_MVC_class?('StreamMethod'))
end #test
test "Association Progression" do
	assert(FullAssociatedModel.instance_respond_to?(:test_table))
	assert(HalfAssociatedModel.instance_respond_to?(:test_table))
	assert(!GenericTableAssociatedModel.instance_respond_to?(:test_table))
	assert(!EmptyAssociatedModel.instance_respond_to?(:test_table))
	assert(!EmptyClass.new.respond_to?(:test_table))

	assert_equal(:to_one, FullAssociatedModel.association_to_type(:test_table))
	assert_equal(:to_one, HalfAssociatedModel.association_to_type(:test_table))
	assert_equal(:not_an_association, GenericTableAssociatedModel.association_to_type(:test_table))
	assert_equal(:not_an_association, EmptyAssociatedModel.association_to_type(:test_table))
	
	assert(TestTable.instance_respond_to?(:full_associated_models))
	assert(!TestTable.instance_respond_to?(:half_associated_model))
	assert(!TestTable.instance_respond_to?(:generic_table_associated_model))
	assert(!TestTable.instance_respond_to?(:empty_associated_model))

	assert_equal(:to_many,TestTable.association_to_type(:full_associated_models))
	assert_equal(:not_an_association,TestTable.association_to_type(:half_associated_model))
	assert_equal(:not_an_association,TestTable.association_to_type(:generic_table_associated_model))
	assert_equal(:not_an_association,TestTable.association_to_type(:empty_associated_model))

	assert(TestTable.is_association?(:full_associated_models))
	assert_equal('test_tables',TestTable.table_name)
	#~ assert(FullAssociatedModel.is_association?(TestTable.table_name),"FullAssociatedModel.is_association?(#{TestTable.table_name})")
	assert(FullAssociatedModel.is_association?(:test_table))
	association_class=TestTable.association_class(:full_associated_models)
	assert(association_class.is_association?(association_class.association_method_symbol(TestTable.table_name.singularize.to_sym)) ,"#{association_class.inspect}.is_association?(#{association_class.association_method_symbol(TestTable.table_name.singularize.to_sym)})")
	assert(TestTable.is_matching_association?(:full_associated_models))
end #test
test "associated_to_s" do
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
end #test
test "matching associations" do
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
end #test
end #test class
