###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'virtus'
# require_relative '../../app/models/no_db.rb'
require_relative '../../app/models/unit.rb'
require_relative '../../app/models/parse.rb'
class Require
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    Relative_regexp = /^require/ * /_relative/.capture(:relative).group * Regexp::Optional * /\s+/ * /['"]/ * FilePattern::Relative_pathname_included_regexp.capture(:required_path)
    Require_regexp = /^require/ * /_relative/.capture(:relative).group * Regexp::Optional * /\s+/ * /['"]/ * FilePattern::Relative_pathname_included_regexp.capture(:required_path) * /['"]/
  end # DefinitionalConstants
  include DefinitionalConstants
  module DefinitionalClassMethods # compute sub-objects such as default attribute values
    include DefinitionalConstants
    def parse_output(code, capture_class = SplitCapture)
      parse = code.capture?(Require_regexp, capture_class).output
    end # parse_output

    def scan(unit)
      ret = {}
      unit.edit_files.each do |file|
        code = IO.read(file)
        parse = code.capture?(Require_regexp).output
        ret = ret.merge(FilePattern.find_from_path(file)[:name] => parse)
      end # each
      ret
    end # scan

    def scan_file(path)
      unit = Unit.new_from_path(path)
      scan(unit)
    end # scan_file
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods
  include Virtus.value_object
  values do
    attribute :unit, Unit
    attribute :requires, Hash, default: ->(require, _attribute) { Require.scan(require.unit) }
    #	attribute :age, Fixnum, :default => 789
    #	attribute :timestamp, Time, :default => Time.now
  end # values
  module ClassMethods
    include DefinitionalConstants
    def all
    end # all
  end # ClassMethods
  extend ClassMethods
  module Constants # constant objects of the type (e.g. default_objects)
  end # Constants
  include Constants
  # attr_reader
  require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
        #	asset_nested_and_included(:ClassMethods, self)
        #	asset_nested_and_included(:Constants, self)
        #	asset_nested_and_included(:Assertions, self)
        self
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
        self
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
      self
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
      self
    end # assert_post_conditions

    def assert_relative(code, regexp)
      assert_match(regexp, code)
      assert_equal('_relative', code.capture?(regexp, MatchCapture).output[:relative])
      split_capture = code.capture?(regexp, SplitCapture)
      assert_equal('_relative', split_capture.raw_captures[1], split_capture.inspect)
      assert_include(split_capture.regexp.names, :relative.to_s, split_capture.inspect)
      assert_equal('_relative', split_capture.to_a(0)[0], split_capture.inspect)
      #      assert_equal('_relative', split_capture.column_output, split_capture.inspect)
      assert_equal(1, split_capture.repetitions?, split_capture.inspect)
      assert_equal(2, split_capture.num_captures, split_capture.inspect)
      (0..split_capture.repetitions? - 1).map do |i|
        assert_equal('_relative', split_capture[0, i], split_capture.inspect)
      end # map
      #      split_capture.output.each_with_index do |_output, i|
      #        assert_equal('_relative', split_capture[0, i], split_capture.inspect)
      #        assert_equal('_relative', Capture.symbolize_keys(split_capture.named_hash(i * (split_capture.num_captures + 1))))
      #        assert_equal('_relative', output[:relative], output.inspect)
      #      end # each
    end # assert_relative
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    include DefinitionalConstants
    include Constants
    Require_line = "require_relative '../../app/models/unit.rb'".freeze
    Executing_requires = Require.new(unit: Unit::Executable)
  end # Examples
end # Require
