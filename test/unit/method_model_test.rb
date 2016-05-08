###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
#require_relative 'test_environment'
require_relative '../../app/models/method_model.rb'
# require_relative '../../app/models/object_memory.rb'
class MethodTest < TestCase
	include Method::Examples
  def test_arity
		assert_equal(0, Instance_method_inspect.arity)
		assert_equal(1, Class_method_ancestor_methods.arity)
#    assert_equal(-1, Script_command_line.method(:candidate_commands).arity)
#    assert_equal(-1, Script_command_line.method(:initialize).arity)
    #	assert_equal(-2, No_args.unit_class.method(:initialize).arity)
    #	assert_equal(-2, Script_command_line.unit_class.method(:initialize).arity)
#    refute_nil(Script_command_line.method(:argument_types))
#    assert_equal(0, Script_command_line.method(:argument_types).arity, Script_command_line.inspect)
#    assert_equal(-1, Script_command_line.method(:executable_object).arity, Script_command_line.inspect)
    #	assert_equal(1, Script_command_line.method(:executable_method).arity, Script_command_line.inspect)
#    assert_equal(0, Script_command_line.method(:number_of_arguments).arity, Script_command_line.inspect)
    #	assert_equal(-1, Test_unit_commandline.medthod(:error_score?).arity, Test_unit_commandline.to_s)

    assert_equal(-1, Example.method(:all_default).arity)
    assert_equal(-2, Example.method(:initialize).arity)
    #	assert_equal(-2, No_args.unit_class.method(:initialize).arity)
    #	assert_equal(-2, Example.unit_class.method(:initialize).arity)
    refute_nil(Example.executable_method?(:argument_types))
    assert_equal(0, Example.arity(:argument_types), Example.inspect)
    assert_equal(-1, Example.arity(:executable_object), Example.inspect)
    assert_equal(1, Example.arity(:executable_method), Example.inspect)
    assert_equal(1, Example.arity(:arity), Example.inspect)
#    assert_equal(-1, Test_unit_commandline.arity(:error_score?), Test_unit_commandline.to_s)
  end # arity

  def test_default_arguments?
		assert_equal(false, Instance_method_inspect.default_arguments?)
		assert_equal(false, Class_method_ancestor_methods.default_arguments?)
#    executable_object = Test_unit_commandline.executable_object
#    message = 'Script_command_line = ' + Script_command_line.inspect
#    assert_equal(false, Script_command_line.method(:argument_types).default_arguments?, message)
#    assert_equal(true, Script_command_line.method(:executable_object).default_arguments?, message)
    #	assert_equal(true, Script_command_line.method(:executable_method).default_arguments?, message)
#    assert_equal(false, Script_command_line.method(:number_of_arguments).default_arguments?, message)
#    executable_object = Test_unit_commandline.executable_object
    message = 'Example = ' + Example.inspect
    assert_equal(false, Example.default_arguments?(:argument_types), message)
    assert_equal(true, Example.default_arguments?(:executable_object), message)
    assert_equal(false, Example.default_arguments?(:executable_method), message)
    assert_equal(false, Example.default_arguments?(:arity), message)
  end # default_arguments

  def test_required_arguments
		assert_equal(0, Instance_method_inspect.required_arguments)
		assert_equal(1, Class_method_ancestor_methods.required_arguments)
#    executable_object = Test_unit_commandline.executable_object
#    assert_equal(:error_score?, Test_unit_commandline.sub_command)
#    assert_respond_to(executable_object, Test_unit_commandline.sub_command)
#    method = executable_object.method(Test_unit_commandline.sub_command)
    #	assert_equal(-1, method.arity)
#    assert_equal(0, method.required_arguments, Test_unit_commandline.to_s)
#    executable_object = Test_unit_commandline.executable_object
#    assert_equal(:error_score?, Test_unit_commandline.sub_command)
#    assert_respond_to(executable_object, Test_unit_commandline.sub_command)
#    method = executable_object.method(Test_unit_commandline.sub_command)
#    assert_equal(-1, method.arity)
#    assert_equal(0, method.required_arguments, Test_unit_commandline.to_s)
  end # required_arguments
end # MethodTest

class MethodModelTest < TestCase
  include RubyAssertions
	include MethodModel::Examples
	def test_superclasses
		assert_equal([BasicObject], MethodModel.superclasses(BasicObject))
		assert_equal([Object, BasicObject], MethodModel.superclasses(Object))
		assert_equal([MethodModel, Object, BasicObject], MethodModel.superclasses(MethodModel))
	end # superclasses
	
		def test_apply_selection_defaults
		assert_equal(Default_method_selection, MethodModel.apply_selection_defaults(Default_method_selection, Default_method_selection))
		assert_equal([:instance, :method_name_selection], Default_method_selection.keys)
		selection = {instance: false}
		assert_equal(false, selection[:instance])
		assert_equal(false, selection[:instance].nil?)
		defaults = Default_method_selection
		assert_equal([:instance], selection.keys)
		defaults.each_pair do |key, value|
			assert_instance_of(Symbol, key)
			assert_include(Default_method_selection.keys, key)
			if selection[key].nil?
				selection[key] = value # default
			end # if
		end # each_pair
		assert_equal({instance: false, :method_name_selection=>/.+/}, selection)
		refute_equal(Default_method_selection, selection)
		assert_equal({instance: false, :method_name_selection=>/.+/}, MethodModel.apply_selection_defaults({instance: false}, Default_method_selection))
	end # apply_selection_defaults

	def test_method_names
		assert_include(MethodModel.method_names(Dir, instance: false), :[], MethodModel.apply_selection_defaults({instance: false}, Default_method_selection))
		assert_include(MethodModel.method_names(MethodModel), :inspect)
		assert_equal([:attribute], MethodModel.method_names(MethodModel, instance: false))
		assert_includes(MethodModel.method_names(BasicObject, method_name_selection: /in/), :instance_eval)

		assert_includes(MethodModel.method_names(MethodModel, method_name_selection: /in/), :inspect)
		refute_includes(MethodModel.method_names(MethodModel, method_name_selection: /catfish/), :inspect)
		Ancestor_method_selections.each do |selection|
			assert_instance_of(Array, MethodModel.method_names(BasicObject, selection))
			MethodModel.assert_ancestor_method_names(BasicObject, selection)
		end # each
		Method_selections.each do |selection|
			assert_instance_of(Array, MethodModel.method_names(BasicObject, selection))
			MethodModel.assert_ancestor_method_names(BasicObject, selection)
		end # each
	end # method_names

	def test_ancestor_method_names
#		method_model_ancestor_hash = MethodModel.class.ancestors.map {|a| {ancestor: a, methods: a.methods(false), instance_methods: a.instance_methods(false)} }
		method_model_ancestor_names = MethodModel.ancestor_method_names(MethodModel)
		assert_equal(MethodModel.ancestors, method_model_ancestor_names.keys)
#		assert_equal(method_model_ancestor_hash, method_model_ancestor_names)
		assert_operator(0, :<, BasicObject.instance_methods(false).size)
		assert_equal(BasicObject.instance_methods(false), MethodModel.method_names(BasicObject))
		assert_equal([BasicObject], BasicObject.ancestors)
		assert_equal(BasicObject.ancestors, MethodModel.ancestor_method_names(BasicObject).keys)
		assert_equal([BasicObject.instance_methods(false)], MethodModel.ancestor_method_names(BasicObject).values)
		assert_equal([BasicObject.methods(false)], MethodModel.ancestor_method_names(BasicObject, instance: false).values)
		assert_equal([Object, BasicObject], MethodModel.superclasses(Object))
		assert_equal([Test::Unit::Assertions, JSON::Ext::Generator::GeneratorMethods::Object, Kernel], Object.included_modules)
		selection = {method_name_selection: /in/}
		assert_equal({BasicObject=> [:instance_eval, :instance_exec]}, MethodModel.ancestor_method_names(BasicObject, method_name_selection: /in/))
		assert_equal({BasicObject=> [:instance_eval, :instance_exec]}, MethodModel.ancestor_method_names(BasicObject, selection))
		selection = {method_name_selection: /instance_variable_.et/, include_inherited: true}
		assert_equal(MethodModel.method_names(Object, selection), MethodModel.ancestor_method_names(Object, selection).values.flatten.uniq, MethodModel.ancestor_method_names(Object, selection))
		selection = {method_name_selection: /.+/, include_inherited: true}
		assert_equal(MethodModel.method_names(Object, selection), MethodModel.ancestor_method_names(Object, selection).values.flatten.uniq, MethodModel.ancestor_method_names(Object, selection))
		assert_equal(MethodModel.ancestor_method_names(Object).values.flatten.uniq, MethodModel.method_names(Object, selection), MethodModel.ancestor_method_names(Object))
		assert_empty(MethodModel.method_names(Object, selection).uniq - MethodModel.method_names(Object).uniq, MethodModel.ancestor_method_names(Object))
		assert_equal(MethodModel.method_names(Object).uniq, MethodModel.method_names(Object, selection).uniq, MethodModel.ancestor_method_names(Object))
		assert_equal(MethodModel.method_names(Object), MethodModel.ancestor_method_names(Object).values.flatten.uniq, MethodModel.ancestor_method_names(Object))
		assert_equal(Object.instance_methods(true), MethodModel.method_names(Object, selection))
		assert_equal(MethodModel.ancestor_method_names(Object).values.flatten.uniq, 
		             MethodModel.ancestor_method_names(Object, selection).values.flatten.uniq, MethodModel.ancestor_method_names(Object, selection))
		assert_equal(Object.instance_methods(true), MethodModel.ancestor_method_names(Object).values.flatten.uniq)
		selection = {method_name_selection: /in/, include_inherited: true}
		assert_equal(MethodModel.method_names(MethodModel, selection), MethodModel.ancestor_method_names(MethodModel, selection).values.flatten.uniq, MethodModel.ancestor_method_names(MethodModel, selection))
		selection = {method_name_selection: /=/, include_inherited: true}
		assert_include(MethodModel.ancestor_method_names(MethodModel, selection).values.flatten.uniq, :attributes=, MethodModel.ancestor_method_names(MethodModel, selection))
		assert_include(MethodModel.instance_methods(true), :attributes)
		assert_include(Virtus::InstanceMethods::MassAssignment.instance_methods(true).select{|m| m.to_s.match(/=/)}, :attributes=, MethodModel.ancestor_method_names(MethodModel, selection).inspect)
		assert_include(Virtus::InstanceMethods::MassAssignment.instance_methods(true), :attributes=, MethodModel.ancestor_method_names(MethodModel, selection).inspect)

		assert_include(MethodModel.instance_methods(true).select{|m| m.to_s.match(/=/)}, :attributes=, MethodModel.ancestor_method_names(MethodModel, selection).inspect)
		assert(MethodModel.instance_methods(true).include?(:attributes=), MethodModel.ancestor_method_names(MethodModel, selection).inspect)
		assert_include(MethodModel.method_names(MethodModel, selection), :attributes=, MethodModel.ancestor_method_names(MethodModel, selection))
		assert_equal(MethodModel.method_names(MethodModel, selection), MethodModel.ancestor_method_names(MethodModel, selection).values.flatten.uniq, MethodModel.ancestor_method_names(MethodModel, selection))
		selection = {method_name_selection: /.+/, include_inherited: true}
		assert_equal(MethodModel.method_names(MethodModel, selection), MethodModel.ancestor_method_names(MethodModel, selection).values.flatten.uniq, MethodModel.ancestor_method_names(MethodModel, selection))

		assert_equal(MethodModel.instance_methods(true).uniq, MethodModel.ancestor_method_names(MethodModel).values.flatten.uniq)
		assert_equal(MethodModel.instance_methods(true), MethodModel.ancestor_method_names(MethodModel).values.flatten.uniq)
		assert_equal(MethodModel.instance_methods(true), method_model_ancestor_names.values.flatten.uniq)
	end # ancestor_method_names
	
	def test_ancestor_method_name
		Ancestor_method_selections.each do |selection|
			assert_instance_of(Hash, MethodModel.ancestor_method_name(BasicObject, selection))
			MethodModel.assert_ancestor_method_names(BasicObject, selection)
			selection[:method_name_selection] = :ancestor_method_names
			selection[:method_name_selection] = :inspect
			assert_instance_of(Hash, MethodModel.ancestor_method_name(BasicObject, selection))
			MethodModel.assert_ancestor_method_names(BasicObject, selection)
		end # each
		method_model_ancestor_names = MethodModel.ancestor_method_names(MethodModel)
#		ancestor_method_name = ancestor_method_names(klass, selection)

		ancestor_method_name_call = MethodModel.ancestor_method_name(MethodModel, inspect: true)
		assert_equal(ancestor_method_name, ancestor_method_name_call)
		assert_include(MethodModel.method_names(Dir, instance: false), :[])
		assert_equal([Dir], MethodModel.ancestor_method_name(Dir, :[], instance: false), MethodModel.method_names(Dir))
		assert_equal([Object], MethodModel.ancestor_method_name(Regexp, :superclass, instance: false))
		assert_equal([Module, Kernel], MethodModel.ancestor_method_name(MethodModel, :[], instance: true))
		assert_equal([], MethodModel.ancestor_method_name(MethodModel, :ancestor_method_names, instance: false))
			ancestors = MethodModel.ancestor_method_name(klass, method_name, selection).each do |ancestor|
				assert_instance_of(Class, ancestor)
				end # each	
	end # ancestor_method_name

  def assert_method_model_initialized(m, owner, _scope)
    assert_instance_of(Class, owner)
    assert_respond_to(owner, :new)
    theMethod = MethodModel.method_query(m, owner)
    mr = MethodModel.new_from_method(theMethod)
    assert_instance_of(MethodModel, mr)
    refute_nil(mr)
    assert_equal(MethodModel, mr.class)
    assert_instance_of(MethodModel, mr)

    assert_equal(mr[:name], m.to_s)
    assert_includes(mr[:scope], [Class, Module])
    assert_equal(mr[:instance_variable_defined], false)
    assert_nil(mr[:private])
    assert_equal(mr[:singleton], false)
    refute_nil(mr[:owner], "owner is nil for mr=#{mr.inspect}")
	end # assert_method_model_initialized

def test_init_path
end # init_path
  def test_method_query
    owner = MethodModel
    m = :name
    objects = 0
    ObjectSpace.each_object(owner) do |object|
      objects += 1
      begin
        theMethod = object.method(m.to_sym)
      rescue StandardError => exc
        puts "exc=#{exc}, object=#{object.inspect}"
      end # begin
      refute_nil(theMethod)
      assert_instance_of(Method, theMethod)
    end # each_object
    assert_operator(objects, :>, 0)
    method = MethodModel.method_query(m, owner)
    #	assert_equal(, )
    refute_nil(method)
    assert_instance_of(Method, method)
  end # method_query

def test_Virtus_value_object
    owner = MethodModel
    scope = :instance
    m = :name
    explain_assert_respond_to(owner.new, m)
    #	assert_equal(mr[:protected], false)
    assert_respond_to(owner.new, m)
    assert_instance_of(Method, owner.new.method(m.to_sym))
    assert_instance_of(Method, owner.new.method(m.to_sym))
    assert_method_model_initialized(m, owner, scope)
    mr = MethodModel.new(name: m, owner: owner, scope: scope)
    #	assert_equal([:init, :theMethod_not_nil, :not_source_location, :rescue_protected, :alphanumeric], mr.init_path)
    owner = MethodModel
    scope = :class
    m = :inspect
    assert_method_model_initialized(m, owner, scope)
    assert_equal_sets(['init_path'], owner.instance_methods(false), "owner=#{owner.inspect}")
    # ?	assert_equal_sets(["inspect", "instantiate_observers", "joins", "instance_method_already_implemented?"],owner.matching_class_methods(/ins/,false))
    # new	assert_instance_of(Method,owner.new.method(m.to_sym))
    # new	assert_instance_of(Method,owner.new.method(m.to_sym))
    # ?	assert_nil(MethodModel.new(m,owner,scope)[:exception])

    # ?	assert_nil(mr[:exception])
end # values

  def test_constantized
    assert_equal(['Symbol'], Module.constants.map(&:objectKind).uniq)
#    assert_includes(MethodModel.constantized.map(&:objectKind).uniq, 'Symbol')
    assert_operator(1000, :>, Module.constants.size)
    assert_operator(MethodModel.constantized.size, :<, MethodModel.classes_and_modules.size)
    assert_operator(100, :<, MethodModel.constantized.size)
    #	puts "Module.constants=#{Module.constants.inspect}"
    method_list = Module.constants.map do |c|
      if c.objectKind == :class || c.objectKind == :module
        new(c)
      end # if
    end # map
    assert_operator(method_list.size, :<, 1000)
    assert_operator(100, :<, method_list.size)
    assert_includes('Class', MethodModel.constantized.map(&:objectKind).uniq)
    puts 'pretty print'
    # ~ pp MethodModel.all
    # ~ refute_nil(new('object_id',Object,:methods))
  end # constantized
	 def test_new_from_method
	 end # new_from_method
	 
	
	def test_class_ancestor_methods
		assert_equal([], MethodModel.class_ancestor_methods(MethodModel).flatten)
		assert_equal([Dir], MethodModel.matching_ancestors(Dir, false, :[]))
	end # class_ancestor_methods
	 def test_matching_ancestors
		method_name == :ancestor_methods
		object = MethodModel
		assert_include(Method.instance_methods(false), :arity)
		instance = true
		assert_equal([Method], MethodModel.matching_ancestors(Method, true, :arity))
#		assert_equal([MethodModel], MethodModel.matching_ancestors(MethodModel, false, :ancestor_methods))
		assert_include(Dir.methods, :[])
		assert_equal([Dir], MethodModel.matching_ancestors(Dir, false, :[]))
		assert_include(Regexp.methods(false), :escape)
		assert_equal([MethodModel, Object, BasicObject], MethodModel.ancestors - MethodModel.included_modules)
		assert_equal([], MethodModel.included_modules - MethodModel.ancestors)
		assert_equal(MethodModel.ancestors, MethodModel.included_modules)
		assert_equal([Regexp], MethodModel.matching_ancestors(Regexp, false, :superclass))
	 end # matching_ancestors
	 
	 def test_method_inheritance
		method_name == :ancestor_methods
			ancestors_selection = klass.ancestors.map do |ancestor|
				selection = {method_name: method_name, ancestor: ancestor, instance: instance, ancestor_methods: ancestor.methods(false)}
				if instance
					selection[:ancestor_methods] = ancestor.instance_methods(false)
				else
					selection[:ancestor_methods] = ancestor.methods(false)
				end # if
				selection[:match] = selection[:ancestor_methods].include?(method_name)
			end # each
			
			assert_instance_of(Array, ancestors_selection)
			assert_operator(1, :<=, ancestors_selection.size)
	#			assert_include(MethodModel.methods(false), :ancestor_methods, ancestors_selection)
	#			assert_equal([], MethodModel.methods(false), ancestors_selection)
	#			assert_equal(true, MethodModel.methods(false).include?(method_name), ancestors_selection)
	#			assert_equal([{:ancestor=>MethodModel, :instance=>false, :match=>true}], ancestors_selection.select {|s| s[:ancestor] == MethodModel && s[:instance] == false}, ancestors_selection)
				assert_equal([{:ancestor=>MethodModel, :instance=>false, :match=>true}], ancestors_selection.select {|s| s[:match]}, ancestors_selection)
	#			assert_equal([MethodModel], ancestors_selection)
	#			assert_equal([], klass.ancestors)
	#			assert_kind_of(Module, ancestors[0])
		end # method_inheritance
		
	 def test_ancestor_methods
		object = MethodModel
		assert_kind_of(Module, object)
		instance = !object.kind_of?(Module)
		assert(!instance)
		if instance
			klass = object.class
			methods = klass.instance_methods(true)
		else
			klass = object
			methods = klass.methods(true)
		end # if
		assert_instance_of(Class, klass)
		models = methods.map do |method_name|
			assert_instance_of(Array, klass.ancestors)
			assert_instance_of(Class, klass.ancestors[0])
			assert_include(klass.ancestors, MethodModel)
			assert_include(klass.ancestors, Object)
			assert_include(klass.ancestors, BasicObject)


			
			ancestors = klass.ancestors.select do |ancestor|
				if instance
					ancestor.instance_methods(false).include?(method_name)
				else
					ancestor.methods(false).include?(method_name)
				end # if
			end # each
			assert_instance_of(Array, ancestors)
			assert_operator(0, :<=, ancestors.size)
#			assert_equal([MethodModel], ancestors)
#			assert_equal([], klass.ancestors)
#			assert_kind_of(Module, ancestors[0])
			ancestors.map do |ancestor|
				assert_kind_of(Module, ancestor)
				assert_include(ancestor.methods(false), method_name)
				MethodModel.new(name: method_name, class_of_receiver: ancestor, class_method: !instance)
			end # map
		end # each
		assert_instance_of(Array, models)
		assert_instance_of(MethodModel, models[0][0])
		models.flatten.each do |method|
			method.assert_pre_conditions
		end # each
		instance_methods = MethodModel.ancestor_methods(object)
		class__methods =  MethodModel.ancestor_methods(object.class)
		class__methods.flatten.each do |m|
			assert(m.class_method, m.inspect)
			assert_kind_of(Module, m.class_of_receiver, m.inspect)
		end  # each
		assert_equal(models, instance_methods)
		method_model_instance_methods = instance_methods.flatten.select do |m|
		#	assert_kind_of(Module, m.class_of_receiver, m.inspect)
			m.class_of_receiver == MethodModel
		end # select
		method_model_class_methods = class__methods.flatten.select do |m|
		#	assert_kind_of(Module, m.class_of_receiver)
			m.class_of_receiver == MethodModel
		end # select
		assert_include(method_model_instance_methods, Instance_method_inspect)
		assert_include(MethodModel.ancestors[2].methods(false), Class_method_ancestor_methods.name)
		assert_include(MethodModel.methods(false), Class_method_ancestor_methods.name)
		assert_include(method_model_class_methods, Class_method_ancestor_methods)
	 end # ancestor_methods
  def test_inspect
  end # inspect

  def test_matching_methods
#    testClass = Unit
    assert_instance_of(Array, testClass.matching_class_methods(//))
    assert_instance_of(Array, testClass.matching_instance_methods(//))
  end # test

  def test_matching_methods_in_context
#    testClass = Unit
    # error message too long	assert_instance_of(Array,testClass.matching_methods_in_context(//,2))
    # error message too long		assert_equal([testClass.canonicalName,testClass.matching_methods(//)],testClass.matching_methods_in_context(//)[0])
    # error message too long			assert_instance_of(Array,testClass.matching_methods_in_context(//,2))
  end # def

def test_assert_method_names
		assert_operator(0, :<, BasicObject.instance_methods(false).size)
		assert_equal(BasicObject.instance_methods(false), MethodModel.method_names(BasicObject))
		assert_equal(BasicObject.instance_methods(false), MethodModel.ancestor_method_names(BasicObject).values.flatten)
		assert_equal(BasicObject.methods(false), MethodModel.ancestor_method_names(BasicObject, instance: false).values.flatten)
	assert_equal([:instance_eval, :instance_exec], MethodModel.method_names(BasicObject, method_name_selection: /in/))
	assert_equal([:instance_values, :instance_variable_names,  :noninherited_public_instance_methods], MethodModel.method_names(Object, method_name_selection: /instance/))
	assert_equal({BasicObject=>[:instance_eval]}, MethodModel.ancestor_method_names(Object, method_name_selection: /instance_eval/))
end # method_names
def test_assert_ancestors
		assert_equal([BasicObject], BasicObject.ancestors)
		assert_equal(BasicObject.ancestors, MethodModel.ancestor_method_names(BasicObject).keys)
end # ancestors

def test_assert_ancestor_method_names(klass, selection = MethodModel::Default_ancestor_method_selection)
	assert_equal({BasicObject=>[:instance_eval, :instance_exec]}, MethodModel.ancestor_method_names(BasicObject, method_name_selection: /in/))
	Ancestor_method_selections.each do |selection|
		MethodModel.assert_ancestor_method_names(BasicObject, selection)
	end # each
	MethodModel.assert_ancestor_method_names(BasicObject)
	Ancestor_method_selections.each do |selection|
		MethodModel.assert_ancestor_method_names(Object, selection)
	end # each
	MethodModel.assert_ancestor_method_names(Object, method_name_selection: /instance_eval/)
	MethodModel.assert_ancestor_method_names(Object, instance: false)
	MethodModel.assert_ancestor_method_names(Object, {instance: true, method_name_selection: /.+/, ancestor_selection: :ancestors})

	MethodModel.assert_ancestor_method_names(Object)
	MethodModel.assert_ancestor_method_names(Dir)
	MethodModel.assert_ancestor_method_names(MethodModel)
end # ancestor_method_names
def test_assert_pre_conditions
		Instance_method_inspect.assert_pre_conditions
#		Class_method_ancestor_methods.assert_pre_conditions
end #assert_pre_conditions
  def test_Examples
		assert_respond_to(Instance_method_inspect.class_of_receiver, Instance_method_inspect.name)
		assert_include(Instance_method_inspect.class_of_receiver.instance_methods(false), Instance_method_inspect.name)
	end # Examples
	def test_Example_Examples
    Example::Examples::Method_arity.assert_pre_conditions
    Example::Examples::Method_require1.assert_pre_conditions
    Example::Examples::Method_require2.assert_pre_conditions
    Example::Examples::Method_require3.assert_pre_conditions
    Example::Examples::Method_all_default.assert_pre_conditions
  end # Examples
end # MethodModel
