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
require_relative '../../app/models/test_executable.rb'
require 'rgl/implicit'
require 'rgl/adjacency'
require 'rgl/dot'
class Require
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    Relative_regexp = /^/ * (/require/ * (/_relative/ .group * Regexp::Optional)).group.capture(:require_command)
    End_of_line_comment = /\s*/ * /#/ * /[^\n]*/.capture(:comment) * /\n/
    Require_regexp = Relative_regexp * /\s+/ * /['"]/ * FilePattern::Relative_pathname_included_regexp.capture(:required_path) * /['"]/
  end # DefinitionalConstants
  include DefinitionalConstants
  module DefinitionalClassMethods # compute sub-objects such as default attribute values
    include DefinitionalConstants
    def capture_to_hash(capture)
      capture.output
    end # capture_to_hash

    def parse_output(path, capture_class = SplitCapture)
      code = IO.read(path)
      parse = capture_to_hash(code.capture?(Require_regexp, capture_class))
    end # parse_output

    def scan_path(path, already_seen = [])
      #      puts 'path = ' + path.to_s
      capture = parse_output(path, SplitCapture)
      capture.enumerate(:map) do |output|
        if output[:require_command] == 'require' # don't recurse
          output[:required_path]
        elsif output[:require_command] == 'require_relative'
          relative_path = Pathname.new(File.dirname(path) + '/' + output[:required_path]).cleanpath
          unless already_seen.include?(File.expand_path(relative_path)) # recursion
            Require.scan_path(relative_path, already_seen << File.expand_path(relative_path))
          end # unless
        else
          raise capture.inspect
        end # if
      end # map
    end # scan_path

    def scan_unit(unit)
      ret = {}
      unit.edit_files.each do |path|
        parse = parse_output(path, SplitCapture)
        ret = ret.merge(FilePattern.find_from_path(path)[:name] => parse)
      end # each
      ret
    end # scan_unit
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods
  include Virtus.value_object
  values do
    attribute :path, Pathname
    attribute :cached_require_captures, Hash, default: ->(require, _attribute) { Require.scan_path(require.path) }
  end # values

  # This function creates a directed graph, with vertices being all loaded modules:
  def require_graph
    RGL::ImplicitGraph.new do |g|
      g.vertex_iterator do |b|
        ObjectSpace.each_object(Module, &b)
      end # vertex_iterator
      g.adjacent_iterator do |x, b|
        x.ancestors.each do |y|
          b.call(y) unless x == y || y == Kernel
        end # ancestors
      end # adjacent_iterator
      g.directed = true
    end # ImplicitGraph
  end # require_graph

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

      def assert_requires(code, regexp)
        assert_match(regexp, code)
        #      assert_equal('_relative', code.capture?(regexp, MatchCapture).output[:relative])
        split_capture = code.capture?(regexp, SplitCapture)
        assert_include(%w(require require_relative), split_capture.raw_captures[1], split_capture.inspect)
        assert_include(split_capture.regexp.names, :require_command.to_s, split_capture.inspect)
        assert_include(%w(require require_relative), split_capture.to_a(0)[0], split_capture.inspect)
        #      assert_equal('_relative', split_capture.column_output, split_capture.inspect)
        assert_operator(1, :<=, split_capture.repetitions?, split_capture.inspect)
        assert_equal({ 'require_command' => [1], 'required_path' => [2] }, split_capture.regexp.named_captures, split_capture.inspect)
        assert_equal(2, split_capture.regexp.named_captures.values.flatten.size, split_capture.inspect)

        assert_equal(2, split_capture.num_captures, split_capture.inspect)
        (0..split_capture.repetitions? - 1).map do |i|
          assert_include(%w(require require_relative), split_capture[0, i], split_capture.inspect)
        end # map
        #      split_capture.output.each_with_index do |_output, i|
        #        assert_equal('_relative', split_capture[0, i], split_capture.inspect)
        #        assert_equal('_relative', Capture.symbolize_keys(split_capture.named_hash(i * (split_capture.num_captures + 1))))
        #        assert_equal('_relative', output[:relative], output.inspect)
        #      end # each
      end # assert_requires

      def assert_path_requires(path)
        code = IO.read(path)
        assert_requires(code, Require::Require_regexp)
      end # assert_path_requires
    end # ClassMethods

    def assert_pre_conditions(message = '')
      message += "In assert_pre_conditions, self=#{inspect}"
      self
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
      message += "In assert_post_conditions, self=#{inspect}"
      self
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    include DefinitionalConstants
    include Constants
    Require_line = "require_relative '../../app/models/unit.rb'".freeze
    No_scan = Require.new(path: $PROGRAM_NAME, cached_require_captures: nil)
    Nonrelative_line = "require 'active_support' # for singularize and pluralize\n".freeze
  end # Examples
end # Require
