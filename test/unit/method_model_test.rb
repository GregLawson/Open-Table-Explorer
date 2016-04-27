###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/method_model.rb'
# require_relative '../../app/models/object_memory.rb'
class MethodTest < TestCase
  def test_arity
    assert_equal(-1, Example.method(:all_default).arity)
    assert_equal(-2, Example.method(:initialize).arity)
    #	assert_equal(-2, No_args.unit_class.method(:initialize).arity)
    #	assert_equal(-2, Example.unit_class.method(:initialize).arity)
    refute_nil(Example.executable_method?(:argument_types))
    assert_equal(0, Example.arity(:argument_types), Example.inspect)
    assert_equal(-1, Example.arity(:executable_object), Example.inspect)
    assert_equal(1, Example.arity(:executable_method), Example.inspect)
    assert_equal(1, Example.arity(:arity), Example.inspect)
    assert_equal(-1, Test_unit_commandline.arity(:error_score?), Test_unit_commandline.to_s)
  end # arity

  def test_default_arguments?
    executable_object = Test_unit_commandline.executable_object
    message = 'Example = ' + Example.inspect
    assert_equal(false, Example.default_arguments?(:argument_types), message)
    assert_equal(true, Example.default_arguments?(:executable_object), message)
    assert_equal(false, Example.default_arguments?(:executable_method), message)
    assert_equal(false, Example.default_arguments?(:arity), message)
  end # default_arguments

  def test_required_arguments
    executable_object = Test_unit_commandline.executable_object
    assert_equal(:error_score?, Test_unit_commandline.sub_command)
    assert_respond_to(executable_object, Test_unit_commandline.sub_command)
    method = executable_object.method(Test_unit_commandline.sub_command)
    assert_equal(-1, method.arity)
    assert_equal(0, method.required_arguments, Test_unit_commandline.to_s)
  end # required_arguments
end # MethodTest
class MethodModelTest < TestCase
  def assert_method_model_initialized(m, owner, _scope)
    assert_instance_of(Class, owner)
    assert_respond_to(owner, :new)
    theMethod = MethodModel.method_query(m, owner)
    mr = MethodModel.new(theMethod)
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
  end #

  def test_method_query
    owner = ActiveRecord::ConnectionAdapters::ColumnDefinition
    m = :to_sql
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

  def test_initialize
    owner = MethodModel
    scope = :instance
    m = :name
    explain_assert_respond_to(owner.new, m)
    #	assert_equal(mr[:protected], false)
    assert_respond_to(owner.new, m)
    assert_instance_of(Method, owner.new.method(m.to_sym))
    assert_instance_of(Method, owner.new.method(m.to_sym))
    assert_method_model_initialized(m, owner, scope)
    mr = MethodModel.new(m, owner, scope)
    assert_equal([:init, :theMethod_not_nil, :not_source_location, :rescue_protected, :alphanumeric], mr.init_path)

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
  end # new

  def test_constantized
    assert_equal(['Symbol'], Module.constants.map(&:objectKind).uniq)
    assert_includes('String', MethodModel.constantized.map(&:objectKind).uniq)
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

  def test_matching_methods
    testClass = Unit
    assert_instance_of(Array, testClass.matching_class_methods(//))
    assert_instance_of(Array, testClass.matching_instance_methods(//))
  end # test

  def test_matching_methods_in_context
    testClass = Unit
    # error message too long	assert_instance_of(Array,testClass.matching_methods_in_context(//,2))
    # error message too long		assert_equal([testClass.canonicalName,testClass.matching_methods(//)],testClass.matching_methods_in_context(//)[0])
    # error message too long			assert_instance_of(Array,testClass.matching_methods_in_context(//,2))
  end # def

  def test_Examples
  end # Examples
end # MethodModel
