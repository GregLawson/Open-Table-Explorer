# coding: utf-8
###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require 'app/models/generic_table_assertion.rb'
class GenericTableAssertionTest < TestCase
  include GenericTableAssertion::KernelMethods
  @@table_name = 'stream_patterns'
  # fixtures @@table_name.to_sym
  # fixtures :table_specs
  require_relative '../assertions/generic_table_examples.rb' #
  # not single generic_table method
  #
  def test_assert_associations
    assert(@@CLASS_WITH_FOREIGN_KEY.belongs_to_association?(@@FOREIGN_KEY_ASSOCIATION_SYMBOL), 'StreamPatternArgument belongs_to stream_pattern')
    assert(@@FOREIGN_KEY_ASSOCIATION_SYMBOL.to_s.classify.constantize.has_many_association?(@@TABLE_NAME_WITH_FOREIGN_KEY), "#{@@FOREIGN_KEY_ASSOCIATION_SYMBOL} does not has_many #{@@TABLE_NAME_WITH_FOREIGN_KEY}")
    assert_associations(@@CLASS_WITH_FOREIGN_KEY, @@FOREIGN_KEY_ASSOCIATION_SYMBOL)
    assert_associations(@@FOREIGN_KEY_ASSOCIATION_SYMBOL, @@CLASS_WITH_FOREIGN_KEY) # reverse arguments of above
  end # assert_associations

  def test_assert_general_associations
    assert_general_associations(@@table_name)
  end # assert_general_associations

  def test_other_association
    model_class = TableSpec
    assert_equal(['frequency_id'], TableSpec.foreign_key_names)
    assert_equal(Set.new(%w(acquisition_interface_id table_spec_id)), Set.new(AcquisitionStreamSpec.foreign_key_names))
    assert_equal([], AcquisitionInterface.foreign_key_names)
    ar_from_fixture = table_specs(:ifconfig)
    assName = :frequency
    assert_instance_of(Symbol, assName, "associated_foreign_key assName=#{assName.inspect}")

    assert_association(ar_from_fixture, assName)
    refute_nil(ar_from_fixture.class.associated_foreign_key_name(assName), "associated_foreign_key_name: ar_from_fixture=#{ar_from_fixture},assName=#{assName})")
    assert_equal('frequency_id', ar_from_fixture.class.associated_foreign_key_name(assName))
  end # test

  def test_assert_active_record_method
    assert(ActiveRecord::Base.instance_methods_from_class.include?(:connection.to_s))
    method_name = :connection
    assert(ActiveRecord::Base.is_active_record_method?(method_name))
    assert_active_record_method(method_name)

    assert(ActiveRecord::Base.is_active_record_method?(:connection))
    assert(TestTable.is_active_record_method?(:connection))
    assert(TestTable.is_active_record_method?(method_name))
  end # assert_active_record_method

  def test_refute_active_record_method
    association_reference = :parameter
    assert(!ActiveRecord::Base.instance_methods_from_class.include?(:parameter.to_s))
    assert(!TestTable.is_active_record_method?(:parameter))
    method_name = :parameter
    assert(!ActiveRecord::Base.is_active_record_method?(method_name))
    refute_active_record_method(method_name)
  end # refute_active_record_method

  def assert_table_exists(table_name)
  end # assert_table_exists

  def test_assert_table
  end # assert_table

  def test_assert_ActiveRecord_table(model_class_name)
  end # assert_ActiveRecord_table

  def test_assert_generic_table
  end # assert_generic_table

  def test_assert_matching_association
    #	assert_matching_association(TestTable,:full_associated_models)
    #	assert(TestTable.is_matching_association?(:full_associated_models))
    assert_matching_association('table_specs', 'frequency')
    assert_raise(Test::Unit::AssertionFailedError) do
      assert_matching_association('acquisitions', 'frequency')
    end # assert_raised
  end # assert_matching_association

  def test_handle_polymorphic
    association_type = StreamMethodArgument.association_arity(:parameter)
    refute_nil(association_type)
    #	assert_includes(association_type,[:to_one,:to_many])
    #	assert_association(StreamMethodArgument,:parameter)
    #	assert_belongs_to_association(StreamMethodArgument,:parameter)
    #	assert(StreamMethodArgument.belongs_to_association?(:parameter))
    #	assert_includes('parameter',StreamMethodArgument.foreign_key_association_names)
    #	assert_equal(:to_one_belongs_to,StreamMethodArgument.association_type(:parameter))
  end # test

  def setup
    #	define_association_names
  end

  def testMethod
    'nice result'
  end # def

  def test_various_assertions
    refute_empty([1])
    assert_includes('acquisition_stream_specs', TableSpec.instance_methods(false))
    ar_from_fixture = table_specs(:ifconfig)
    refute_nil ar_from_fixture.class.similar_methods(:acquisition_stream_spec)
  end # test

  def test_unknown
    class_reference = StreamMethodArgument
    association_reference = :stream_method
    klass = class_reference
    association_reference = association_reference.to_sym
    refute_empty(ActiveRecord::Base.instance_methods_from_class)
    refute_includes(association_reference.to_s, ActiveRecord::Base.instance_methods_from_class)
    if ActiveRecord::Base.instance_methods_from_class(true).include?(association_reference.to_s)
      raise "# Don’t create associations that have the same name (#{association_reference})as instance methods of ActiveRecord::Base (#{ActiveRecord::Base.instance_methods_from_class.inspect})."
    end # if
    assert_instance_of(Symbol, association_reference, 'assert_association')
    if klass.module_included?(Generic_Table)
      association_type = klass.association_arity(association_reference)
      refute_nil(association_type)
      assert_includes(association_type, [:to_one, :to_many])
    end # if
    # ~ explain_assert_respond_to(klass.new,(association_reference.to_s+'=').to_sym)
    # ~ assert_public_instance_method(klass.new,association_reference,"association_type=#{association_type}, ")
    assert(klass.is_association?(association_reference), "fail is_association?, klass.inspect=#{klass.inspect},association_reference=#{association_reference}")
    assert_association(class_reference, association_reference)
  end # test
end # class
