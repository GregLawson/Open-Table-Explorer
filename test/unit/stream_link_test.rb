###########################################################################
#    Copyright (C) 2011 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class StreamLinkTest < TestCase
  #	ActiveSupport::TestCase::fixtures :stream_method_arguments
  def test_logical_primary_key
  end # logical_key

  def test_fire
  end # fire

  def test_association_names
    assert_generic_table('StreamLink')
    assert_equal_sets([:input_stream_method_argument_id, :output_stream_method_argument_id, :store_method_id, :next_method_id], StreamLink.foreign_key_names)
    assert_equal_sets(%w(output_stream_method_argument next_method input_stream_method_argument store_method), StreamLink.association_names)
    refute_empty(StreamLink.all)
    refute_empty(StreamMethodArgument.all)
    StreamLink.find(:all).each do |sl|
      refute_nil(sl)
    end # each
  end # association_names

  def test_output_stream_method_argument
    refute_empty(@@association_patterns)
    refute_empty(StreamLink.association_patterns(:output_stream_method_argument))
    assert_equal(@@association_patterns, StreamLink.association_patterns(:output_stream_method_argument))

    assert_foreign_key_name(StreamLink, :output_stream_method_argument_id)
    assert_association(StreamLink, :output_stream_method_argument)
    explain_assert_respond_to(StreamLink, :association_macro_type)
    assert_equal(:belongs_to, StreamLink.association_macro_type(:output_stream_method_argument))
    StreamLink.find(:all).each do |sl|
      refute_nil(sl)
      refute_nil(StreamMethodArgument.where('id=?', sl.output_stream_method_argument_id))
      unless sl.association_has_data(:output_stream_method_argument)
        assert_equal('', sl.association_state(:output_stream_method_argument))
      end # if
      assert_equal('Output', StreamMethodArgument.where('id=?', sl.output_stream_method_argument_id).first.direction)
      refute_nil(sl.output_stream_method_argument)
    end # each
  end # output_stream_method_argument

  def test_input_stream_method_argument
    assert_equal(@@association_patterns, StreamLink.association_patterns(:input_stream_method_argument))
    assert_foreign_key_name(StreamLink, :output_stream_method_argument_id)
    assert_association(StreamLink, :input_stream_method_argument)
    assert_equal(:belongs_to, StreamLink.association_macro_type(:input_stream_method_argument))
    StreamLink.find(:all).each do |sl|
      refute_nil(sl)
      unless sl.association_has_data(:input_stream_method_argument)
        assert_equal('Input', input_stream_method_argument.where('id=?', sl.input_stream_method_argument_id).first.direction, message)
        assert_equal('', sl.association_state(:input_stream_method_argument))
      end # if
      message = "StreamMethodArgument.where('id=?',#{sl.input_stream_method_argument_id})=#{StreamMethodArgument.where('id=?', sl.input_stream_method_argument_id).inspect}, sl.input_stream_method_argument_id=#{sl.input_stream_method_argument_id}, "
      refute_nil(sl.input_stream_method_argument)
    end #
  end # input_stream_method_argument

  def test_store_method
  end # store_method

  def test_next_method
  end # next_method

  def setup
    @testURL = 'http://192.168.3.193/api/LiveData.xml'
    define_model_of_test # allow generic tests
    assert_module_included(Unit::Executable.model_class?, Generic_Table)
    explain_assert_respond_to(Unit::Executable.model_class?, :sequential_id?, "#{@model_name}.rb probably does not include include Generic_Table statement.")
    assert_respond_to(Unit::Executable.model_class?, :sequential_id?, "#{@model_name}.rb probably does not include include Generic_Table statement.")
    #	define_association_names #38271 associations
  end # def

  def test_id_equal
    assert(!model_class?.sequential_id?, "model_class?=#{model_class?}, should not be a sequential_id.")
    assert_test_id_equal
  end # test_id_equal
end # StreamLink
