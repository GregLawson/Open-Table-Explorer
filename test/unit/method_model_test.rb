###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
# require_relative 'test_environment'
require_relative '../../app/models/method_model.rb'
# require_relative '../../app/models/object_memory.rb'
class MethodTest < TestCase
  include Method::Examples
  def test_arity
    assert_equal(0, Instance_method_inspect.arity)
    assert_equal(-2, Class_method_method_names.arity)
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

    #    assert_equal(-1, Example.method(:all_default).arity)
    #    assert_equal(-2, Example.method(:initialize).arity)
    #	assert_equal(-2, No_args.unit_class.method(:initialize).arity)
    #	assert_equal(-2, Example.unit_class.method(:initialize).arity)
    #    refute_nil(Example.executable_method?(:argument_types))
    #    assert_equal(0, Example.arity(:argument_types), Example.inspect)
    #    assert_equal(-1, Example.arity(:executable_object), Example.inspect)
    #    assert_equal(1, Example.arity(:executable_method), Example.inspect)
    #    assert_equal(1, Example.arity(:arity), Example.inspect)
    #    assert_equal(-1, Test_unit_commandline.arity(:error_score?), Test_unit_commandline.to_s)
  end # arity

  def test_default_arguments?
    assert_equal(false, Instance_method_inspect.default_arguments?)
    assert_equal(true, Class_method_method_names.default_arguments?)
    #    executable_object = Test_unit_commandline.executable_object
    #    message = 'Script_command_line = ' + Script_command_line.inspect
    #    assert_equal(false, Script_command_line.method(:argument_types).default_arguments?, message)
    #    assert_equal(true, Script_command_line.method(:executable_object).default_arguments?, message)
    #	assert_equal(true, Script_command_line.method(:executable_method).default_arguments?, message)
    #    assert_equal(false, Script_command_line.method(:number_of_arguments).default_arguments?, message)
    #    executable_object = Test_unit_commandline.executable_object
    message = 'Example = ' + Example.inspect
    #    assert_equal(false, Example.default_arguments?(:argument_types), message)
    #    assert_equal(true, Example.default_arguments?(:executable_object), message)
    #    assert_equal(false, Example.default_arguments?(:executable_method), message)
    #    assert_equal(false, Example.default_arguments?(:arity), message)
  end # default_arguments

  def test_required_arguments
    assert_equal(0, Instance_method_inspect.required_arguments)
    assert_equal(1, Class_method_method_names.required_arguments)
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

  def test_echo_selection
    assert_equal({}, MethodModel.echo_selection)
    assert_equal({ include_inherited: false, instance: false, method_name_selection: /.+/ }, MethodModel.echo_selection(include_inherited: false, instance: false, method_name_selection: /.+/))
    assert_equal(Default_method_selection, MethodModel.echo_selection(Default_method_selection))
    refute_equal(Default_method_selection, MethodModel.echo_selection(selection: Default_method_selection))
    assert_equal(123, MethodModel.echo_selection(123))
    assert_equal({ selection: 123 }, MethodModel.echo_selection(selection: 123))
    # wrong # args			assert_equal(123, MethodModel.echo_selection(123, instance: false))
  end # echo_selection

  def test_apply_selection_defaults
    assert_equal(Default_method_selection, MethodModel.apply_selection_defaults(Default_method_selection, Default_method_selection))
    assert_equal([:instance, :method_name_selection, :include_inherited], Default_method_selection.keys)
    selection = { instance: false }
    assert_equal(false, selection[:instance])
    assert_equal(false, selection[:instance].nil?)
    defaults = Default_method_selection
    assert_equal([:instance], selection.keys)
    ret = selection.clone # copy to modify, in case constant passed as selection
    # OBE    assert_equal([Object], MethodModel.ancestor_method_names(Default_method_selection.class, selection: { method_name_selection: :freeze }).keys)
    defaults.each_pair do |key, value|
      assert_instance_of(Symbol, key)
      assert_include(Default_method_selection.keys, key)
      if selection[key].nil?
        ret[key] = value # default
      end # if
    end # each_pair
    #    assert_equal({ include_inherited: false, instance: false, method_name_selection: /.+/ }, selection)
    refute_equal(Default_method_selection, selection)
    assert_equal({ include_inherited: false, instance: false, method_name_selection: /.+/ }, MethodModel.apply_selection_defaults({ instance: false }, Default_method_selection))
end # apply_selection_defaults

  def test_method_names
    assert_include(MethodModel.method_names(Dir, instance: false), :[], MethodModel.apply_selection_defaults({ instance: false }, Default_method_selection))
    assert_include(MethodModel.method_names(MethodModel), :inspect)
    assert_equal([:attribute], MethodModel.method_names(MethodModel, instance: false))
    assert_includes(MethodModel.method_names(BasicObject, method_name_selection: /in/), :instance_eval)

    assert_includes(MethodModel.method_names(MethodModel, method_name_selection: /in/), :inspect)
    assert_includes(MethodModel.method_names(MethodModel, method_name_selection: [:inspect]), :inspect)
    assert_includes(MethodModel.method_names(MethodModel, method_name_selection: :inspect), :inspect)

    assert_equal([:inspect], MethodModel.method_names(MethodModel, method_name_selection: /ins/))
    assert_equal([:inspect], MethodModel.method_names(MethodModel, method_name_selection: [:inspect]))
    assert_equal([:inspect], MethodModel.method_names(MethodModel, method_name_selection: :inspect))

    assert_equal([:freeze], MethodModel.method_names(Object, include_inherited: true, method_name_selection: /fre/))
    assert_equal([:freeze], MethodModel.method_names(Default_method_selection.class, include_inherited: true, method_name_selection: /fre/))
    assert_equal([:freeze], MethodModel.method_names(Object, method_name_selection: [:freeze]))
    assert_equal([:freeze], MethodModel.method_names(Object, method_name_selection: :freeze))

    assert_includes(MethodModel.method_names(Object, method_name_selection: :inspect), :inspect)
    assert_includes(MethodModel.method_names(Default_method_selection.class, method_name_selection: :inspect), :inspect)
    assert_includes(MethodModel.method_names(Default_method_selection.class, method_name_selection: :freeze), :freeze)
    assert_equal([:freeze], MethodModel.method_names(Default_method_selection.class, method_name_selection: :freeze))
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
    # picky    assert_equal([Test::Unit::Assertions, JSON::Ext::Generator::GeneratorMethods::Object, Kernel], Object.included_modules)
    selection = { method_name_selection: /in/ }
    assert_equal({ BasicObject => [:instance_eval, :instance_exec] }, MethodModel.ancestor_method_names(BasicObject, method_name_selection: /in/))
    assert_equal({ BasicObject => [:instance_eval, :instance_exec] }, MethodModel.ancestor_method_names(BasicObject, selection))
    selection = { method_name_selection: /instance_variable_.et/, include_inherited: true }
    assert_equal(MethodModel.method_names(Object, selection), MethodModel.ancestor_method_names(Object, selection).values.flatten.uniq, MethodModel.ancestor_method_names(Object, selection))
    selection = { method_name_selection: /.+/, include_inherited: true }
    assert_equal(MethodModel.method_names(Object, selection), MethodModel.ancestor_method_names(Object, selection).values.flatten.uniq, MethodModel.ancestor_method_names(Object, selection))
    assert_equal(MethodModel.ancestor_method_names(Object).values.flatten.uniq, MethodModel.method_names(Object, selection), MethodModel.ancestor_method_names(Object))
    #    assert_empty(MethodModel.method_names(Object, selection).uniq - MethodModel.method_names(Object).uniq, MethodModel.ancestor_method_names(Object))
    #    assert_equal(MethodModel.method_names(Object).uniq, MethodModel.method_names(Object, selection).uniq, MethodModel.ancestor_method_names(Object))
    #    assert_equal(MethodModel.method_names(Object), MethodModel.ancestor_method_names(Object).values.flatten.uniq, MethodModel.ancestor_method_names(Object))
    assert_equal(Object.instance_methods(true), MethodModel.method_names(Object, selection))
    assert_equal(MethodModel.ancestor_method_names(Object).values.flatten.uniq,
                 MethodModel.ancestor_method_names(Object, selection).values.flatten.uniq, MethodModel.ancestor_method_names(Object, selection))
    assert_equal(Object.instance_methods(true), MethodModel.ancestor_method_names(Object).values.flatten.uniq)
    selection = { method_name_selection: /in/, include_inherited: true }
    assert_equal(MethodModel.method_names(MethodModel, selection), MethodModel.ancestor_method_names(MethodModel, selection).values.flatten.uniq, MethodModel.ancestor_method_names(MethodModel, selection))
    selection = { method_name_selection: /=/, include_inherited: true }
    assert_include(MethodModel.ancestor_method_names(MethodModel, selection).values.flatten.uniq, :attributes=, MethodModel.ancestor_method_names(MethodModel, selection))
    assert_include(MethodModel.instance_methods(true), :attributes)
    assert_include(Virtus::InstanceMethods::MassAssignment.instance_methods(true).select { |m| m.to_s.match(/=/) }, :attributes=, MethodModel.ancestor_method_names(MethodModel, selection).inspect)
    assert_include(Virtus::InstanceMethods::MassAssignment.instance_methods(true), :attributes=, MethodModel.ancestor_method_names(MethodModel, selection).inspect)

    #    assert_include(MethodModel.instance_methods(true).select { |m| m.to_s.match(/=/) }, :attributes=, MethodModel.ancestor_method_names(MethodModel, selection).inspect)
    #    assert(MethodModel.instance_methods(true).include?(:attributes=), MethodModel.ancestor_method_names(MethodModel, selection).inspect)
    #    assert_include(MethodModel.method_names(MethodModel, selection), :attributes=, MethodModel.ancestor_method_names(MethodModel, selection))
    #    assert_equal(MethodModel.method_names(MethodModel, selection), MethodModel.ancestor_method_names(MethodModel, selection).values.flatten.uniq, MethodModel.ancestor_method_names(MethodModel, selection))
    selection = { method_name_selection: /.+/, include_inherited: true }
    #    assert_equal(MethodModel.method_names(MethodModel, selection), MethodModel.ancestor_method_names(MethodModel, selection).values.flatten.uniq, MethodModel.ancestor_method_names(MethodModel, selection))

    #    assert_equal(MethodModel.instance_methods(true).uniq, MethodModel.ancestor_method_names(MethodModel).values.flatten.uniq)
    #    assert_equal(MethodModel.instance_methods(true), MethodModel.ancestor_method_names(MethodModel).values.flatten.uniq)
    #    assert_equal(MethodModel.instance_methods(true), method_model_ancestor_names.values.flatten.uniq)
  end # ancestor_method_names

  def test_prototype_list
    prototype_list = MethodModel.method_names(MethodModel).map do |method_name|
      MethodModel.new(ancestor: MethodModel, method_name: method_name, instance: true)
                 .prototype(ancestor_qualifier: true, argument_delimeter: ' ')
    end # map
    assert_match(/theMethod /, prototype_list.join)
    assert_match(/^theMethod \n/, MethodModel.prototype_list(MethodModel, ancestor_qualifier: false, argument_delimeter: ' ').join)
    #    assert_match(/catfish /, MethodModel.prototype_list(MethodModel).join)
  end # prototype_list

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
    #    ancestor_method_name = ancestor_method_names(klass, selection)

    ancestor_method_name_call = MethodModel.ancestor_method_name(MethodModel, inspect: true)
    #    assert_equal(ancestor_method_name, ancestor_method_name_call)
    assert_include(MethodModel.method_names(Dir, instance: false), :[])
    #    assert_equal([Dir], MethodModel.ancestor_method_name(Dir, :[], instance: false), MethodModel.method_names(Dir))
    #    assert_equal([Object], MethodModel.ancestor_method_name(Regexp, :superclass, instance: false))
    #    assert_equal([Module, Kernel], MethodModel.ancestor_method_name(MethodModel, :[], instance: true).keys)
    #    assert_equal([], MethodModel.ancestor_method_name(MethodModel, :ancestor_method_names, instance: false))
    #    ancestors = MethodModel.ancestor_method_name(klass, method_name, selection).each do |ancestor|
    #      assert_instance_of(Class, ancestor)
    #    end # each
  end # ancestor_method_name

  def assert_method_model_initialized(m, ancestor, _instance)
    assert_instance_of(Class, ancestor)
    assert_respond_to(ancestor, :new)
    theMethod = MethodModel.method_query(m, ancestor)
    mr = MethodModel.new_from_method(theMethod)
    assert_instance_of(MethodModel, mr)
    refute_nil(mr)
    assert_equal(MethodModel, mr.class)
    assert_instance_of(MethodModel, mr)

    #    assert_equal(mr[:name], m)
    #    assert_includes(mr[:instance], [Class, Module])
    #    assert_equal(mr[:instance_variable_defined], false)
    #    assert_nil(mr[:private])
    #    assert_equal(mr[:singleton], false)
    refute_nil(mr[:ancestor], "ancestor is nil for mr=#{mr.inspect}")
  end # assert_method_model_initialized

  def test_init_path
  end # init_path

  def test_first_object
    assert_includes(MethodModel.objects_query(MethodModel), MethodModel.first_object(MethodModel))
    assert_equal(nil, MethodModel.first_object(Math))
  end # first_object

  def test_objects_query
    ancestor = MethodModel
    ret = []
    ObjectSpace.each_object(ancestor) do |object|
      assert_instance_of(ancestor, object)
      ret << object
    end # each_object
    ret.each do |object|
      assert_instance_of(ancestor, object)
    end # each
    assert_equal(ret, MethodModel.objects_query(MethodModel))
    assert_includes(MethodModel.objects_query(MethodModel), Instance_method_inspect)
    assert_includes(MethodModel.objects_query(MethodModel), Class_method_method_names)
    assert_equal([], MethodModel.objects_query(Math))
  end # objects_query

  def test_method_query
    ancestor = MethodModel
    m = :method_name
    objects = 0
    ObjectSpace.each_object(ancestor) do |object|
      assert_respond_to(object, m)
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
    method = MethodModel.method_query(m, ancestor)
    #	assert_equal(, )
    refute_nil(method)
    assert_instance_of(Method, method)
  end # method_query

  def test_Virtus_value_object
    ancestor = MethodModel
    instance = true
    m = :method_name
    explain_assert_respond_to(ancestor.new, m)
    #	assert_equal(mr[:protected], false)
    assert_respond_to(ancestor.new, m)
    assert_instance_of(Method, ancestor.new.method(m.to_sym))
    assert_instance_of(Method, ancestor.new.method(m.to_sym))
    assert_method_model_initialized(m, ancestor, instance)
    mr = MethodModel.new(name: m, ancestor: ancestor, instance: instance)
    #	assert_equal([:init, :theMethod_not_nil, :not_source_location, :rescue_protected, :alphanumeric], mr.init_path)
    ancestor = MethodModel
    instance = :class
    m = :inspect
    assert_method_model_initialized(m, ancestor, instance)
    #    assert_equal_sets(['init_path'], ancestor.instance_methods(false), "ancestor=#{ancestor.inspect}")
    # ?	assert_equal_sets(["inspect", "instantiate_observers", "joins", "instance_method_already_implemented?"],ancestor.matching_class_methods(/ins/,false))
    # new	assert_instance_of(Method,ancestor.new.method(m.to_sym))
    # new	assert_instance_of(Method,ancestor.new.method(m.to_sym))
    # ?	assert_nil(MethodModel.new(m,ancestor,instance)[:exception])

    # ?	assert_nil(mr[:exception])
  end # values

  def test_constantized
    assert_equal(['Symbol'], Module.constants.map(&:objectKind).uniq)
    #    assert_includes(MethodModel.constantized.map(&:objectKind).uniq, 'Symbol')
    #    assert_operator(1000, :>, Module.constants.size)
    #    assert_operator(MethodModel.constantized.size, :<, MethodModel.classes_and_modules.size)
    assert_operator(100, :<, MethodModel.constantized.size)
    #	puts "Module.constants=#{Module.constants.inspect}"
    method_list = Module.constants.map do |c|
      if c.objectKind == :class || c.objectKind == :module
        new(c)
      end # if
    end # map
    assert_operator(method_list.size, :<, 1000)
    assert_operator(100, :<, method_list.size)
    #    assert_includes(MethodModel.constantized.map(&:objectKind).uniq, 'Class')
    #    puts 'pretty print'
    # ~ pp MethodModel.all
    # ~ refute_nil(new('object_id',Object,:methods))
  end # constantized

  def test_MethodModel_virtus
    assert_equal([:@parent, :@attributes, :@index], MethodModel.attributes.instance_variables)
    assert_equal(Object, MethodModel.attributes.parent)
    assert_equal([], MethodModel.attributes.methods(false))
    assert_equal({ ancestor: MethodModel, instance: true, method_name: :inspect, new_from_method: nil }, Instance_method_inspect.attributes)
    # long    assert_equal({}, Class_method_method_names.attributes)
    attribute_index = MethodModel.attributes.instance_variable_get(:@index)
    assert_instance_of(Hash, attribute_index)
    assert_equal(%w(method_name ancestor instance new_from_method), attribute_index.keys.map(&:to_s).uniq)
    assert_instance_of(Virtus::Attribute, attribute_index['method_name'])
    assert_equal([], attribute_index[:method_name].methods(false))
    assert_equal([:@type, :@primitive, :@options, :@default_value, :@coercer, :@name, :@instance_variable_name], attribute_index[:method_name].instance_variables)
    assert_equal(Axiom::Types::Symbol, attribute_index[:method_name].type)
    assert_equal(Symbol, attribute_index[:method_name].primitive)
    # long    assert_equal({}, attribute_index[:method_name].options)
    assert_equal(nil, attribute_index[:method_name].default_value.value)
    # long    assert_equal(nil, attribute_index[:method_name].coercer)
    assert_equal(:method_name, attribute_index[:method_name].name)
    assert_equal('@method_name', attribute_index[:method_name].instance_variable_name)
    assert_equal(attribute_index['method_name'].inspect, attribute_index[:method_name].inspect)
    assert(attribute_index['method_name'].equal?(attribute_index[:method_name]))
    #    assert_equal(attribute_index['method_name'], attribute_index[:method_name])
    # long    assert_equal([], MethodModel.attributes.instance_variable_get(:@attributes))
  end # values

  def test_new_from_method
  end # new_from_method

  def test_inspect
  end # inspect

  def test_prototype
    assert_equal("MethodModel#inspect()\n", Instance_method_inspect.prototype)
    assert_equal("method_names arg ...\n",
                 Class_method_method_names.prototype(ancestor_qualifier: false, argument_delimeter: ' '))
  end # prototype

  def test_theMethod
    assert_equal(0, Instance_method_inspect.theMethod.arity, Instance_method_inspect)
    assert_equal(:method_names, Class_method_method_names.theMethod.name, Class_method_method_names)
  end # theMethod

  def test_matching_methods_in_context
    #    testClass = Unit
    # error message too long	assert_instance_of(Array,testClass.matching_methods_in_context(//,2))
    # error message too long		assert_equal([testClass.canonicalName,testClass.matching_methods(//)],testClass.matching_methods_in_context(//)[0])
    # error message too long			assert_instance_of(Array,testClass.matching_methods_in_context(//,2))
  end # def

  def test_assert_MethodModel_pre_conditions
  end # assert_pre_conditions

  def test_MethodModel_assert_post_conditions
  end # assert_post_conditions

  def test_assert_method_names
    assert_operator(0, :<, BasicObject.instance_methods(false).size)
    assert_equal(BasicObject.instance_methods(false), MethodModel.method_names(BasicObject))
    assert_equal(BasicObject.instance_methods(false), MethodModel.ancestor_method_names(BasicObject).values.flatten)
    assert_equal(BasicObject.methods(false), MethodModel.ancestor_method_names(BasicObject, instance: false).values.flatten)
    assert_equal([:instance_eval, :instance_exec], MethodModel.method_names(BasicObject, method_name_selection: /in/))
    assert_equal([:instance_values, :instance_variable_names, :noninherited_public_instance_methods], MethodModel.method_names(Object, method_name_selection: /instance/))
    assert_equal({ BasicObject => [:instance_eval] }, MethodModel.ancestor_method_names(Object, method_name_selection: /instance_eval/))
  end # method_names

  def test_assert_ancestors
    assert_equal([BasicObject], BasicObject.ancestors)
    assert_equal(BasicObject.ancestors, MethodModel.ancestor_method_names(BasicObject).keys)
  end # ancestors

  def test_assert_ancestor_method_names
    assert_equal({ BasicObject => [:instance_eval, :instance_exec] }, MethodModel.ancestor_method_names(BasicObject, method_name_selection: /in/))
    Ancestor_method_selections.each do |selection|
      MethodModel.assert_ancestor_method_names(BasicObject, selection)
    end # each
    MethodModel.assert_ancestor_method_names(BasicObject)
    Ancestor_method_selections.each do |selection|
      MethodModel.assert_ancestor_method_names(Object, selection)
    end # each
    #    MethodModel.assert_ancestor_method_names(Object, method_name_selection: /instance_eval/)
    #    MethodModel.assert_ancestor_method_names(Object, instance: false)
    #    MethodModel.assert_ancestor_method_names(Object, instance: true, method_name_selection: /.+/, ancestor_selection: :ancestors)

    #    MethodModel.assert_ancestor_method_names(Object)
    #    MethodModel.assert_ancestor_method_names(Dir)
    #    MethodModel.assert_ancestor_method_names(MethodModel)
  end # ancestor_method_names

  def test_assert_pre_conditions
    Instance_method_inspect.assert_pre_conditions
    #		Class_method_method_names.assert_pre_conditions
  end # assert_pre_conditions

  def test_assert_post_conditions
  end # assert_post_conditions

  def test_Examples
    assert_respond_to(Instance_method_inspect.ancestor, Instance_method_inspect.method_name)
    assert_include(Instance_method_inspect.ancestor.instance_methods(false), Instance_method_inspect.method_name)
  end # Examples

  def test_Example_Examples
    Example::Examples::Method_arity.assert_pre_conditions
    Example::Examples::Method_require1.assert_pre_conditions
    Example::Examples::Method_require2.assert_pre_conditions
    Example::Examples::Method_require3.assert_pre_conditions
    Example::Examples::Method_all_default.assert_pre_conditions
  end # Examples
end # MethodModel
