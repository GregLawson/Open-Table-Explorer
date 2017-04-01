###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require 'test/assertions/example_type_assertions.rb'
class ExampleTypeTest < TestCase
  @@test_name = name
  @@model_name = @@test_name.sub(/Test$/, '').sub(/Controller$/, '')
  @@table_name = @@model_name.tableize
  fixtures @@table_name.to_sym
  def test_generic_type
    ExampleType.all.each do |t|
      message = "t=#{t.inspect}, t.generic_type=#{t.generic_type.inspect}"
      refute_nil(t.generic_type, message)
    end # each
  end # generic_type

  def test_which_generic_type
    ExampleType.all.each do |t|
      message = "t=#{t.inspect}, t.generic_type=#{t.generic_type.inspect}"
      refute_nil(t.which_generic_type, message)
      refute_nil(t.which_generic_type(:generalize), message)
      refute_nil(t.which_generic_type(:specialize), message)
      refute_nil(t.generic_type.specialize, message)
      assert_instance_of(Array, t.generic_type.specialize, message)
      assert_respond_to(t.generic_type.specialize, :class, message)
      refute_nil(t.generic_type.specialize.class, message)
      refute_nil(t.generic_type.specialize.class.name, message)
      #		refute_empty(t.generic_type.specialize, message)
      #		refute_empty(t.which_generic_type(:specialize), message)
      assert_instance_of(GenericType, t.which_generic_type, message)
      assert_instance_of(GenericType, t.which_generic_type(:generalize), message)
      assert_instance_of(Array, t.which_generic_type(:specialize), message)
      #		t.assert_generic_type(nil, "t=#{t.inspect}, t.generic_type=#{t.generic_type.inspect}, t.generic_type=#{t.generic_type.inspect}", message)
      #		t.assert_generic_type(:generalize, "t=#{t.inspect}, t.generic_type=#{t.generic_type.inspect}, t.generic_type=#{t.generic_type.inspect}", message)
      #		t.assert_generic_type(:specialize, "t=#{t.inspect}, t.generic_type=#{t.generic_type.inspect}, t.generic_type=#{t.generic_type.inspect}", message)
    end # each
  end # which_generic_type

  def test_assert_specialization_does_not_match
    example = ExampleType.find_by_example_string('*')
    regexp = GenericType.find_by_import_class('word')
    assert_equal(regexp.generalize, example.generic_type)
    assert_no_match(Regexp.new(regexp[:data_regexp]), example[:example_string])
    specializations = example.generic_type.one_level_specializations
    refute_empty(specializations)
    assert(specializations.any? do |s|
      if Regexp.new(s[:data_regexp]).match(example[:example_string])
        $LAST_MATCH_INFO[0] != example[:example_string]
      else
        true # no match
      end # if
    end, "import_class=#{example.generic_type[:import_class]}, self=#{example.inspect}, specializations=#{specializations.inspect}") # any
    if Regexp.new(regexp[:data_regexp]).match(example[:example_string])
      refute_equal($LAST_MATCH_INFO[0], example[:example_string])
    end # if
    ExampleType.all.each(&:assert_specialization_does_not_match) # each
  end # assert_specialization_does_not_match

  def test_assert_no_example_duplicates
    ExampleType.all.each(&:assert_no_example_duplicates) # each
  end # assert_no_example_duplicates

  def test_assert_generic_type
    ExampleType.all.each do |t|
      t.assert_generic_type(nil, 'example not valid')
      t.assert_generic_type(:generalize, 'generalize not valid')
      t.assert_generic_type(:specialize, 'specialize not valid')
    end # each
  end # generic_type
end # ExampleType
