###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/stream_method.rb'
class StreamMethod < ActiveRecord::Base
  include Test::Unit::Assertions
  # require 'rails/test_help'
  module Examples
    HTTP_method = StreamMethod.find_by_name(:HTTP)
  end # Examples
  include Examples
  module Assertions
    include DefaultAssertions
    module ClassMethods
      include DefaultAssertions::ClassMethods
      def assert_pre_conditions
        assert(!sequential_id?, "class=#{self}, should not be a sequential_id.")
        StreamMethod.all.map do |u|
        end # map
        #	fail "end of class assert_pre_conditions "
      end # assert_pre_conditions

      def self.assert_no_syntax_error(code)
        method_def = "def syntax_check_temp_method\n#{code}\nend\n"
        instance_eval(method_def)
        return true
      rescue SyntaxError => exception_raised
        return false
      end # def
    end # ClassMethods

    def assert_acq_and_rescue
      stream = acquisition_stream_specs(@testURL.to_sym)
      acq = HTTP_method.clone
      acq.interface_method
      assert(!acq.interaction.error.nil? || !acq.interaction.acquisition_data.empty?)
    rescue StandardError => exception_raised
      puts 'Error: ' + exception_raised.inspect + ' could not get data from ' + stream.url
      puts "$!=#{$ERROR_INFO}"
    end # def

    def assert_gui_name
      acq = HTTP_method.clone
      assert_equal('@input', acq.gui_name('input'))
    end # gui_name

    def assert_instance_name_reference
      acq = HTTP_method.clone
      assert_equal('self[:input]', acq.instance_name_reference('input'))
    end # instance_name_reference

    def assert_default_method
      acq = HTTP_method.clone
      assert_equal('@acquisition=@uri', acq.default_method)
    end # default_method

    def assert_map_io
      acq = HTTP_method.clone
      code = acq.default_method
      name = 'uri'
      assert_equal('@acquisition=self[:uri]', code.gsub(acq.gui_name(name), acq.instance_name_reference(name)))
      name = 'acquisition'
      assert_equal('self[:acquisition]=@uri', code.gsub(acq.gui_name(name), acq.instance_name_reference(name)))
      name = 'uri'
      code = code.gsub(acq.gui_name(name), acq.instance_name_reference(name))
      assert_equal('@acquisition=self[:uri]', code.gsub(acq.gui_name(name), acq.instance_name_reference(name)))
      name = 'acquisition'
      code = code.gsub(acq.gui_name(name), acq.instance_name_reference(name))
      assert_equal('self[:acquisition]=self[:uri]', code.gsub(acq.gui_name(name), acq.instance_name_reference(name)))
      assert_equal('', acq.map_io(''))
      assert_equal('self[:acquisition]=self[:uri]', acq.map_io(acq.default_method))
    end # map_io

    def assert_eval_method
      acq = HTTP_method.clone
      code = acq.interface_code
      if code.nil? || code.empty?
        rows = 0
        cols = 0
      else
        code_lines = code.split("\n")
        rows = code_lines.size
        cols = code_lines.map(&:length).max
      end # if
      assert_operator(rows, :>, 0)
      assert_operator(cols, :>, 0)
      acq.compile_code!
      explain_assert_respond_to(acq, :interface_code_method)
      assert_includes('interface_code_method', acq.methods(true))
      #	acq.eval_method(:interface_code,'')
      assert_includes('interface_code_rows', acq.methods(true))
      assert_includes('interface_code_rows', acq.singleton_methods(true))
      explain_assert_respond_to(acq, :interface_code_rows)
      refute_nil(acq.interface_code_rows)
    end # eval_method

    def assert_compile_code
      acq = HTTP_method.clone
      assert_instance_of(StreamMethod, acq)
      #	puts "acq.matching_methods(/code/).inspect=#{acq.matching_methods(/code/).inspect}"
      acq.compile_code!
      refute_nil(acq)
      @my_fixtures.each_value do |acq|
        assert_instance_of(StreamMethod, acq)
        #		puts "acq.matching_methods(/code/).inspect=#{acq.matching_methods(/code/).inspect}"
        acq.compile_code!
        # ~ if acq.self[:errorz]=self[:errorz].empty? then
        # ~ puts "No error in acq=#{acq.interface_code.inspect}"
        # ~ else
        # ~ puts "acq.self[:errorz]=self[:errorz]=#{acq.self[:errorz]=self[:errorz].inspect} for acq=#{acq.interface_code.inspect}"
        # ~ end #if
        refute_nil(acq)
        assert(!acq.respond_to?(:syntax_check_temp_method), "syntax_check_temp_method is a method of #{canonicalName}.")
      end # each_value
    end # compile_code

    def assert_active_model_error(field = nil, expected_error_message_regexp = nil)
      if expected_error_message_regexp.instance_of?(String)
        expected_error_message_regexp = expected_error_message_regexp.to_exact_regexp
      end # if
      assert_instance_of(ActiveModel::Errors, errors)
      assert_instance_of(Array, errors.keys)
      assert_instance_of(Array, errors.values)
      if field.nil?
        assert_active_model_error(:interface_code)
        assert_active_model_error(:rescue_code)
        assert_active_model_error(:return_code)
        assert_empty(syntax_errors?)
      elsif expected_error_message_regexp.nil?
        assert_empty(errors[field], "errors[#{field}]=#{errors[field]}")
      else
        message = "errors[#{field}]=#{errors[field]}\nfull_messages=#{errors.full_messages.inspect}"
        assert_instance_of(ActiveModel::Errors, errors, message)
        assert_instance_of(Array, errors.keys, message)
        assert_instance_of(Array, errors.values, message)
        assert_instance_of(Symbol, errors.keys[0], message)
        assert_includes(field, errors.keys, message)
        assert_instance_of(Array, errors.values[0], message)
        assert_instance_of(String, errors.values[0][0], message)
        refute_nil(syntax_errors?, message)
        assert_instance_of(Array, errors[field], message)
        assert_equal(1, errors[field].size, message)
        assert_operator(1, :<=, errors.size, message)
        errors[field].each do |error|
          RegexpMatch.explain_assert_match(expected_error_message_regexp, error, message)
        end # each
      end # if
      expected_errors = ActiveSupport::OrderedHash[[:interface_code, ["SyntaxError: #<SyntaxError: (eval):4:in `eval_method': compile error\n(eval):3: syntax error, unexpected tPOW, expecting kEND>"]], nil]
      refute_nil(expected_errors)
    end # assert_no_syntax_error

    def assert_input_stream_names
      acq = HTTP_method.clone
      stream_pattern_arguments = acq.stream_pattern.stream_pattern_arguments
      stream_inputs = stream_pattern_arguments.select { |a| a.direction == 'Input' }
      assert_equal(['URI'], stream_inputs.map(&:name))
      assert_equal(['uri'], acq.input_stream_names)
    end # input_stream_names

    def assert_output_stream_names
      acq = HTTP_method.clone
      stream_pattern_arguments = acq.stream_pattern.stream_pattern_arguments
      stream_outputs = stream_pattern_arguments.select { |a| a.direction == 'Output' }
      assert_equal(['Acquisition'], stream_outputs.map(&:name))
      assert_equal(['acquisition'], acq.output_stream_names)
    end # output_stream_names

    def assert_field_firing_error(field = nil, expected_error_message_regexp = nil)
      assert_active_model_error(field, expected_error_message_regexp)
      self[:interface_code] = interface_code
      assert_instance_of(StreamMethod, self)
      #	puts "self.matching_methods(/code/).inspect=#{self.matching_methods(/code/).inspect}"
      compile_code!
      self[:uri] = 'http://192.168.100.1'
      assert(has_attribute?(:uri))
      assert(!has_attribute?(:errors))
      assert_equal(ActiveModel::Errors.new('err'), errors)
      assert_equal([], errors.full_messages)

      firing = fire!
      assert_equal(interface_code_errors, firing.errors[:interface_code], "interface_code=#{firing[:interface_code]}")
      assert_equal(acquisition_errors, firing.errors[:acquisition])
      refute_empty(firing.errors)
      refute_empty(firing.errors.inspect)
      assert_instance_of(ActiveModel::Errors, firing.errors)
      assert_instance_of(Array, firing.errors.full_messages)
      assert_instance_of(StreamMethod, firing)
      assert_kind_of(StreamMethod, firing)
      assert_equal(firing, self)
      assert_equal('http://192.168.100.1', firing.uri)
      firing.errors.clear # so we can run more tests
    end # assert_field_firing_error

    def assert_fire
      acq = HTTP_method.clone
      fire_check(acq.interface_code, ['#<NoMethodError: undefined method `uri\' for "http://192.168.100.1":String>'], ['is empty.'])
      fire_check(acq.default_method, [], [])
      assert_equal('http://192.168.100.1', acq[:acquisition])
      @my_fixtures.each_pair do |_key, sm|
        assert_instance_of(StreamMethod, sm)
        fire_check(sm.default_method, [], [])
      end # each
    end # fire

    def assert_errors
      acq = HTTP_method.clone
      assert(!acq.has_attribute?(:errors))
      assert_instance_of(ActiveModel::Errors, acq.errors)
      assert_instance_of(Array, acq.errors.full_messages)
      assert_equal({}, acq.errors)
      assert_equal([], acq.errors.full_messages)
      acq.errors.add(:acquisition, 'is bad.')
      assert_equal(['Acquisition is bad.'], acq.errors.full_messages)
      # fails	assert_equal({[:acquisition, ["is bad."]]=>nil}, acq.errors)
      # fails	assert_equal({[:acquisition, ["is bad."]]=>nil}.inspect, acq.errors.to_hash.inspect)
      acq.errors.add(:errors, 'is worse.')
      assert_equal(2, acq.errors.count)
      assert_equal(['is bad.'], acq.errors[:acquisition])
      assert_equal(['is worse.'], acq.errors[:errors])
      assert_equal([:acquisition, :errors], acq.errors.keys)
      assert_equal("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>\n  <error>Acquisition is bad.</error>\n  <error>Errors is worse.</error>\n</errors>\n", acq.errors.to_xml)
      # fails	assert_equal({[:acquisition, ["is bad."]]=>nil, [:errors, ["is worse."]]=>nil}, acq.errors.as_json)
      assert_equal(['Acquisition is bad.', 'Errors is worse.'], acq.errors.full_messages)
      assert_equal(['Acquisition is bad.', 'Errors is worse.'], acq.errors.to_a)
      acq.errors.clear
    end # errors

    def assert_invariant
      assert_instance_of(StreamMethod, self)
      assert(!respond_to?(:syntax_check_temp_method), "syntax_check_temp_method is a method of #{canonicalName}.")

      input_streams.each do |stream|
        assert_instance_of(StreamMethodArgument, stream)
        code = code.gsub(stream.gui_name, stream.instance_name_reference)
        #		code=code+":input(#{stream.gui_name}, #{instance_name_reference(stream)})"
      end # each
    end # class_assert_invariant

    def assert_pre_conditions
      input_streams.each do |input|
      end # each
      assert_empty(syntax_errors?)
      assert_equal(0, errors.count)
      #	fail "end of instance assert_pre_conditions"
    end # assert_pre_conditions

    def assert_post_conditions
      input_streams.each do |input|
      end # each
      assert(!respond_to?(:syntax_check_temp_method), "syntax_check_temp_method is a method of #{canonicalName}.")
      assert_empty(syntax_errors?)
      #	fail "end of instance assert_pre_conditions"
    end # assert_pre_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
end # StreamMethod
