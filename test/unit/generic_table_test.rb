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
class GenericTableTest < ActiveSupport::TestCase
include Generic_Table
@@table_name='stream_patterns'
	fixtures :table_specs
	fixtures :acquisition_stream_specs
	fixtures :acquisition_interfaces
assert_equal([GenericTableTest], Module.nesting)
assert_not_include(GenericGrep, self.included_modules)
assert_equal('constant', defined? GenericGrep)
ASSOCIATION_MACRO_PATTERN=GenericGrep::ClassMethods::ASSOCIATION_MACRO_PATTERN
def test_NoDB
end #NoDB
def test_association_refs
	class_reference=StreamPattern
	association_reference=:stream_methods
	ActiveRecord::Base.association_refs(class_reference, association_reference) do |class_reference, association_reference|
	assert_instance_of(Symbol,association_reference,"In association_refs, association_reference=#{association_reference} must be a Symbol.")
	assert_instance_of(Class,class_reference,"In test_is_association, class_reference=#{class_reference} must be a Class.")
#	assert_kind_of(ActiveRecord::Base,class_reference)
	assert_ActiveRecord_table(class_reference.name)
		assert_instance_of(Symbol,association_reference,"In association_refs, association_reference=#{association_reference} must be a Symbol.")
		assert_instance_of(Class,class_reference,"In test_is_association, class_reference=#{class_reference} must be a Class.")
	#	assert_kind_of(ActiveRecord::Base,class_reference)
		assert_ActiveRecord_table(class_reference.name)
	end #association_refs
	assert_equal([StreamPattern, :stream_methods], ActiveRecord::Base.association_refs(StreamPattern, :stream_methods) { |class_reference, association_reference| [class_reference, association_reference]})
end #association_refs
def test_model_file_name
end #model_file_name
def test_grep_command
	assert_equal("grep \"#{ASSOCIATION_MACRO_PATTERN}\" -r {app/models/,test/unit/}*.rb", ActiveRecord::Base::grep_command(ASSOCIATION_MACRO_PATTERN))
	assert_equal("", `#{ActiveRecord::Base::grep_command(ASSOCIATION_MACRO_PATTERN)}`)
end #grep_command
def test_model_grep_command
	assert_equal('grep "belongs_to" app/models/stream_pattern.rb &>/dev/null', StreamPattern.model_grep_command('belongs_to'))
end #model_grep_command
def test_model_grep
	assert_equal("has_many :stream_pattern_arguments\nhas_many :stream_methods\n", StreamPattern.model_grep('has_many'))
	assert_equal("has_many :stream_methods\n", StreamPattern.model_grep("has_many :stream_methods"))
	assert_equal("has_many :stream_pattern_arguments\nhas_many :stream_methods\n", StreamPattern.model_grep(ASSOCIATION_MACRO_PATTERN))
	assert_model_grep(StreamPattern, 'has_many')
	assert_model_grep(StreamPattern,"has_many :stream_methods")
	assert_model_grep(StreamPattern, ASSOCIATION_MACRO_PATTERN)
end #model_grep
def test_association_grep_pattern
	assert_equal("has_many :stream_methods", StreamPattern.association_grep_pattern('has_many ',:stream_methods))
	assert_equal('', StreamPattern.association_grep('belongs_to',:stream_methods))
end #association_grep_command
def test_grep_all_associations_command
	assert_equal("grep \"#{ASSOCIATION_MACRO_PATTERN}\" app/models/*.rb", TestRun.grep_all_associations_command)
end #grep_all_associations_command
def test_all_associations
	assert_not_empty(ActiveRecord::Base.all_associations)
end #all_associations
def test_association_macro_type
	assert_match(Regexp.new(ASSOCIATION_MACRO_PATTERN),"has_many :stream_pattern_arguments\nhas_many :stream_methods\n")
 	assert_model_grep(StreamPattern, :stream_methods)
 	assert_model_grep(StreamPattern, ASSOCIATION_MACRO_PATTERN)
 	assert_model_grep(StreamPattern, ASSOCIATION_MACRO_PATTERN+' *:stream_methods')
 	assert_equal("has_many :stream_methods\n", StreamPattern.association_grep(ASSOCIATION_MACRO_PATTERN, :stream_methods))
	assert_equal(:has_many, StreamPattern.association_macro_type(:stream_methods))
	assert_equal(:has_many,StreamPattern.association_macro_type(:stream_methods))
	assert_equal(:has_one,Acquisition.association_macro_type(:acquisition_stream_spec))
	assert_equal(:belongs_to, StreamMethod.association_macro_type(:stream_pattern))
	assert_nil(StreamMethod.association_macro_type(:stream_patterns))
	assert_equal(:belongs_to, StreamMethod.association_macro_type(:stream_pattern))
end #association_macro_type
def test_association_grep
	assert_equal('has_many :stream_methods', StreamPattern.association_grep_pattern('has_many ',:stream_methods))
	assert_equal('belongs_to :stream_methods', StreamPattern.association_grep_pattern('belongs_to ',:stream_methods))
	assert_equal("has_many :stream_methods\n", StreamPattern.association_grep('has_many ',:stream_methods))
	assert_equal("", StreamPattern.association_grep('belongs_to',:stream_methods))
	assert_equal("^[hb][has_manyoneblgtd]*  *:stream_methods", StreamPattern.association_grep_pattern(ASSOCIATION_MACRO_PATTERN, :stream_methods))
	assert_equal("^[hb][has_manyoneblgtd]*  *:stream_methods", StreamPattern.association_grep_pattern(ASSOCIATION_MACRO_PATTERN, :stream_methods))
	assert_equal("has_many :stream_methods\n", StreamPattern.association_grep(ASSOCIATION_MACRO_PATTERN, :stream_methods))
end #association_grep
def test_has_many_association
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

	association_name=ar_from_fixture.class.association_method_symbol(assName)
	assert_public_instance_method(ar_from_fixture,association_name)
#	ASSNAME=ar_from_fixture.class.association_method_symbol(assName)
#	assert_public_instance_method(ar_from_fixture,ASSNAME)

#	assert_equal_sets(["has_one", "has_many", "has_and_belongs_to_many"],Frequency.new.matching_instance_methods(/^has_/))
end #has_many_association
def test_belongs_to_association
	assert_equal("belongs_to :stream_pattern\n", StreamMethod.association_grep('',:stream_pattern))
	assert_belongs_to_association(StreamMethod,:stream_pattern)
	assert_raises(Test::Unit::AssertionFailedError){assert_belongs_to_association(StreamMethod,:stream_patterns)}
	assert_equal(:belongs_to, StreamMethod.association_macro_type(:stream_pattern))
	assert(StreamMethod.belongs_to_association?(:stream_pattern))
	assert_equal(:has_many, StreamPattern.association_macro_type(:stream_method))
	assert(StreamPattern.has_many_association?(:stream_method))
	assert_equal('', StreamPattern.association_grep('^belongs_to',:stream_methods))
	assert(!StreamPattern.belongs_to_association?(:stream_methods),"")
	assert(!StreamPattern.belongs_to_association?(:stream_method))

end #belongs_to_association
def test_has_one_association
	assert(Acquisition.has_one_association?(:stream_patterns))
end #has_one_association
def warn_association_type(table, association_name)
	klass=Generic_Table.class_of_name(table)
	new_type= klass.association_type(association_name)
	assert_associations(table, association_name)
	if new_type==:to_many_ || new_type==:to_one_ then
		puts "table=#{table.inspect}, association_name=#{association_name.inspect}, new_type=#{new_type.inspect}"
		puts klass.association_arity(association_name)
		puts klass.association_macro_type(association_name)

		puts klass.association_class(association_name).association_arity(table)
		puts klass.association_class(association_name).association_macro_type(table)

	end #if
	return new_type
rescue  StandardError => exception_raised
	return "#{table}::#{association_name}" #exception_raised.to_s
end #warn_association_type
def test_association_type
	assert_equal(:to_one_belongs_to, StreamMethod.association_type(:stream_pattern))
	warn_association_type(StreamMethod, :stream_pattern)
	types=[] # nothing found yet
	mvc_names=CodeBase.rails_MVC_classes.map { |klass| klass.name }
	assert_not_nil(mvc_names)
	mvc_names.each do |table|
		klass=Generic_Table.class_of_name(table)
		klass.association_names.each do |association_name|
			types << warn_association_type(table, association_name)
		end #associations
	end #tables
	association_types= types.uniq
	assert_empty(association_types-[:to_many_has_many, :to_one_belongs_to, :to_one_has_one])
end #association_type
def test_is_active_record_method
	association_reference=:inputs
	assert(ActiveRecord::Base.instance_methods_from_class.include?(:connection.to_s))
	assert(!ActiveRecord::Base.instance_methods_from_class.include?(:parameter.to_s))
	assert(!TestTable.is_active_record_method?(:parameter))
	assert(TestTable.is_active_record_method?(:connection))
end #active_record_method
def test_single_grep
	pattern='(\w+)\.all'
	regexp=Regexp.new(pattern)
	line='Url.all'
	context=line
	matchData=regexp.match(line)
	if matchData then
		ActiveSupport::HashWithIndifferentAccess.new(:context => context, :matchData => matchData)
	else
		nil #don't select line for return
	end #if
	assert_instance_of(ActiveSupport::HashWithIndifferentAccess, line.single_grep(line, pattern))
	assert_equal("Url.all", line.single_grep(line, pattern)[:context])
#	assert_equal(matchData, line.single_grep(line, pattern)[:matchData])
	assert_equal(matchData[1], line.single_grep(line, pattern)[:matchData][1])
end #single_grep
def test_nested_grep
	pattern='(\w+)\.all'
	file_regexp=['app/controllers/urls_controller.rb']
	assert_equal([], file_regexp.nested_grep(file_regexp, pattern))
end #nested_grep
def test_files_grep
	pattern='(\w+)\.all'
	file_regexp=['app/controllers/urls_controller.rb']
	pathnames=RegexpTree.new(file_regexp).pathnames
	assert_instance_of(Array, pathnames)
	assert_module_included(Array, Enumerable)
	pathnames.files_grep(pattern).each do |p|
		assert_instance_of(ActiveSupport::HashWithIndifferentAccess, p)
		assert_equal(file_regexp[0], p[:context])
	#	assert_equal(matchData, pathnames.files_grep(pattern)[:matchData])
#		matchData=regexp.match(line)
#		assert_equal(matchData[1], p[:matchData][1])
	end #each
end #files_grep
def test_grep
	file_regexp='app/controllers/urls_controller.rb'
	pattern='(\w+)\.all'
	delimiter="\n"
	regexp=Regexp.new(pattern)
	ps=RegexpTree.new(file_regexp).pathnames
	p=ps.first
	assert_equal([p], ps)
	assert_instance_of(String, p)
	l=IO.read(p).split(delimiter).first
	assert_instance_of(String, l)
	matchData=regexp.match(l)
	assert_instance_of(Hash, {:pathname => p, :match => 'Url'})
	if matchData then
		assert_instance_of(Hash, {:pathname => p, :match => matchData[1]})
	end #if
	grep_matches=Generic_Table.grep(file_regexp, pattern)
	assert_instance_of(Array, grep_matches)
	assert_equal([{:match=>"Url", :pathname=>"app/controllers/urls_controller.rb"}], grep_matches)
	assert_instance_of(Hash, grep_matches[0])
	assert_equal(file_regexp, grep_matches[0][:pathname])
	assert_equal('Url', grep_matches[0][:match])
end #grep
def test_class_of_name
	assert_nil(Generic_Table.class_of_name('junk'))
	assert_equal(StreamPattern, Generic_Table.class_of_name('StreamPattern'))
end #class_of_name
def test_is_generic_table
	assert_raises(Test::Unit::AssertionFailedError){assert(Generic_Table.is_generic_table?('EEG'))}
	assert_raises(Test::Unit::AssertionFailedError){assert(Generic_Table.is_generic_table?('MethodModel'))}
	assert(Generic_Table.is_generic_table?('StreamPattern'))
end #def
def test_table_exists
	assert(Generic_Table.rails_MVC_class?(StreamPattern))
end #table_exists
def test_rails_MVC_class
	assert_raises(Test::Unit::AssertionFailedError){assert(Generic_Table.rails_MVC_class?('junk'))}
	assert_raises(Test::Unit::AssertionFailedError){assert(Generic_Table.rails_MVC_class?('TestHelper'))}
	assert_raises(Test::Unit::AssertionFailedError){assert(Generic_Table.rails_MVC_class?('EEG'))}
	assert_raises(Test::Unit::AssertionFailedError){assert(Generic_Table.rails_MVC_class?('MethodModel'))}
	assert(Generic_Table.rails_MVC_class?(StreamPattern))
end #rails_MVC_class
def test_is_generic_table_name
end #is_generic_table_name
def test_activeRecordTableNotCreatedYet?
end #activeRecordTableNotCreatedYet
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
def test_aaa
	acquisition_stream_spec=acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KHHR.xml'.to_sym)

	assert(AcquisitionStreamSpec.instance_methods(false).include?('acquisition_interface'))
	assert(AcquisitionStreamSpec.instance_methods(false).include?('table_spec'))
	assert_public_instance_method(acquisition_stream_spec,:acquisition_interface)

assert_equal(Fixtures::identify(:HTTP),acquisition_stream_spec.acquisition_interface_id)
	assert_equal(acquisition_stream_spec.acquisition_interface_id,acquisition_interfaces(:HTTP).id)
	assert_equal(acquisition_stream_spec.scheme,acquisition_interfaces(:HTTP).scheme)
	assert_equal(acquisition_stream_spec.scheme,acquisition_stream_spec.acquisition_interface.scheme)
	testCall(acquisition_stream_spec,:acquisition_interface)
	assert_association(acquisition_stream_spec,:acquisition_interface)
#	assert_equal('',acquisitions(:one).associated_to_s(:acquisition_stream_spec,:url))
end
def test_Generic_Table
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
	assert_include('StreamMethod',CodeBase.rails_MVC_classes.map {|c| c.name})
	assert(CodeBase.rails_MVC_classes.map {|c| c.name}.include?('StreamMethod'))
	assert(Generic_Table.rails_MVC_class?('StreamMethod'))
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
end #test
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
def setup
#	ActiveSupport::TestCase::fixtures :acquisition_stream_specs
end #setup
end #test class
