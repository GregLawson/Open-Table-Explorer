###########################################################################
#    Copyright (C) 2014-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/ruby_lines_storage.rb'
require_relative '../../app/models/enumerator.rb'
# merge in rgl library and begin porting to it
# require 'rgl/adjacency'
# require 'rgl/dot'
# begin old graph code
require 'virtus'
# An attempt at a universal data type?
# Or is it duck typing modules without inheritance?
# A Stream is a generalization of Array, Enumerable allowing infinite length part of which can be a Tree data store
# A tree is a generalization of Tables and Nested Arrays and Hashes
# in context see http://rubydoc.info/gems/gratr/0.4.3/file/README
# simple construction would give a tree
# sharing nodes would give a directed acyclic graph
# loops might be possible since ruby objects are references and self references are possible
# require_relative '../../app/models/no_db.rb'
# require_relative 'parse.rb'
# GraphPath
# Useful for indexing parallel trees.
class GraphPath < Array # nested Array
  def initialize(*params)
    if params.empty? || params == [nil] || params.nil? || params == [Root_path]
      super(0) # root?
    elsif params.size == 1
      if params[0].is_a?(Array)
        super(2) { |index| params[0][index] } # how I wish super(params) would work
      else
        []
      end # if
    elsif params.size == 2 && (params[0].instance_of?(GraphPath) || params[0].nil?) && params[1].instance_of?(Fixnum)
      super(2) { |index| params[index] } # how I wish super(params) would work
    else
      message = 'Parent address in GraphPath.new must be a GraphPath or nil for root.'
      message += 'params.class = ' + params.class.name
      message += 'params.size = ' + params.size.to_s
      message += 'params = ' + params.inspect
      raise message
    end # if
  end # initialize

  def deeper
    GraphPath.new(self, 0)
  end # deeper

  def parent_index
    GraphPath.new(self[0])
  end # parent_index

  def child_index
    self[1]
  end # child_index
  module Constants
    Root_path = GraphPath.new
  end # Constants
  include Constants
  module Assertions
    module ClassMethods
      def assert_pre_conditions(message = '')
        assert_includes(Array, ancestors)
        message += "In assert_pre_conditions, self=#{inspect}"
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions(_message = '')
      assert_nil(self[0])
      self[1..-1].assert_Array_of_Class(Fixnum) # parent id nil index
    end # assert_pre_conditions

    def assert_post_conditions(message = '')
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples
    include Constants
    Redundant_root = [Root_path, nil].freeze
    First_son = [Root_path, 0].freeze
    Seventh_son = [Root_path, 6].freeze
    First_grandson = [First_son, 0].freeze
  end # Examples
end # GraphPath
# Connectivity

class Connectivity
  module ClassMethods
    def ref(tree)
      Node.new(node: tree, graph_type: self)
    end # ref

    def [](*params)
      Node.new(node: params, graph_type: self)
    end # square_brackets

    # override if terminals are same type as nonterminals
    def leaf_typed?
      true
    end # leaf_typed?

    def children_if_exist?(node, children_method_name)
      if node.respond_to?(children_method_name)
        children = node.send(children_method_name)
        message = 'Method named ' + children_method_name.to_s + 'does not return an Array (Enumerable?).'
        raise message unless children.instance_of?(Array)
        children
      end # if
    end # children?

    # override for non-default ways of finding children
    def children?(node)
      children_if_exist?(node, :to_a)
    end # children?

    # Shortcut for lack of children is a leaf node.
    # unlike the usual assumption nil means the node has no children_function
    def nonterminal?(node)
      children = children?(node)
      if children.nil?
        nil
      else
        !children.empty?
      end # if
    end # nonterminal?

    def each_pair(children)
      children.each_with_index do |element, index|
        if element.instance_of?(Array) && element.size == 2 # from Hash#to_a
          yield(element[0], element[1])
        else
          yield(index, element)
        end # if
      end # if
    end # each_pair

    def map_pair(children)
      ret = [] # return Array
      each_pair(children) { |key, value| ret. << yield(key, value) }
      ret
    end # map_pair

    def inspect_node(node)
      unless block_given? # default node inspection
        inspect_proc = proc { |e|	e.inspect }

      end # if
      yield(node)
    end # inspect_node

    def map_recursive(node = @node, depth = 0, &visit_proc)
      # Handle missing parameters (since any and all can be missing)
      #	puts 'children_method_name.inspect =' + children_method_name.inspect
      #	puts 'depth.inspect =' + depth.inspect
      #	puts 'visit_proc.inspect =' + visit_proc.inspect
      #	puts 'block_given? =' + block_given?.inspect
      if !block_given? && depth.instance_of?(Proc)
        raise 'Block proc argument should be preceded with ampersand.'
      end # if
      nonterminal = nonterminal?(node)
      if nonterminal
        children = children?(node)
        [yield(ref(node), depth, false), map_pair(children) do |_index, sub_tree|
          map_recursive(sub_tree, depth + 1, &visit_proc)
        end] # map
      else
        yield(ref(node), depth, nonterminal) # end recursion
      end # if
    end # map_recursive

    def inspect_nonterminal?(node)
      case nonterminal?(node)
      when true then	'nonterminal'
      when false then leaf_typed? ? 'leaf_typed is childless error' : 'leaf childless'
      when nil then leaf_typed? ? 'leaf typed' : 'leaf_typed error'
      else 'unknown'
      end # case
    end # inspect_nonterminal?

    def inspect_recursive(node = @node, &inspect_proc)
      unless block_given?
        inspect_proc = proc do |node, depth, _terminal|
          ret = inspect_nonterminal?(node)
          ret += '[' + depth.to_s + ']'
          ret += ', '
          ret += node.graph_type.inspect_node(node.node)
        end # Tree_node_format
      end # if
      ret = map_recursive(node, &inspect_proc)
      ret = if ret.instance_of?(Array)
              ret.join("\n")
            else
              ret
      end # if
      ret + "\n"
    end # inspect_recursive
  end # ClassMethods
  extend ClassMethods
  module Assertions
    module ClassMethods
      # assertions before module has been completely defined
      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
        assert_equal(self, Connectivity, message)
        assert_includes(ancestors, Connectivity)
        #	assert_equal(self.ancestors, [Connectivity])
        #	assert_equal(self.included_modules, [], message)
        assert_includes(Connectivity.ancestors, Connectivity)
        assert_empty(Connectivity::ClassMethods.methods(false), message)
        assert_includes(Connectivity::ClassMethods.instance_methods(false), :each_pair)
        assert_includes(Connectivity::ClassMethods.instance_methods(false), :ref)
        assert_empty(Connectivity.instance_methods(false))
        refute_includes(Connectivity.methods(false), :each_pair)
        assert_includes(Connectivity.methods, :each_pair)
        assert_includes(Connectivity.methods, :ref)
        assert_includes(Connectivity.methods, :map_recursive)
        assert_respond_to(Connectivity, :inspect_node)
        assert_respond_to(Connectivity, :map_recursive)
        assert_equal('1', Connectivity.inspect_node(1))
      end # assert_pre_conditions

      # assertions after module has been completely defined
      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
      end # assert_post_conditions
    end # ClassMethods
  end # Assertions
  extend Assertions::ClassMethods
  # self.assert_pre_conditions
  module Examples
    Node_format = proc do |e|
      e.inspect
    end # Node_format
    Tree_node_format = proc do |node, depth, terminal|
      ret = case terminal
            when true then	'terminal'
            when false then 'nonterminal'
            when nil then 'terminal'
            else 'unknown'
      end # case
      ret += '[' + depth.to_s + ']'
      ret += ', '
      ret += node.graph_type.inspect_node(node.node)
    end # Tree_node_format
    Children_method_name = :to_a
    Example_array = [1, 2, 3].freeze
    Nested_array = [1, [2, [3], 4], 5].freeze
    Inspect_node_root = '[1, [2, [3], 4], 5]'.freeze
    Children_nested_array = [[2, 3, 4]].freeze
    Son_nested_array = [2, [3], 4].freeze
    Grandchildren_nested_array = [[3]].freeze
    Grandson_nested_array = 3
    Tree_node_root = 'nonterminal[0], [1, [2, [3], 4], 5]'.freeze
    Grandson_nested_array_map = 'terminal[2], 3'.freeze
    Son_nested_array_map = ['nonterminal[1], [2, [3], 4]',
                            ['terminal[2], 2',
                             ['nonterminal[2], [3]', ['terminal[3], 3']],
                             'terminal[2], 4']].freeze
    Nested_array_map = ['nonterminal[0], [1, [2, [3], 4], 5]',
                        ['terminal[1], 1',
                         ['nonterminal[1], [2, [3], 4]',
                          ['terminal[2], 2',
                           ['nonterminal[2], [3]', ['terminal[3], 3']],
                           'terminal[2], 4']],
                         'terminal[1], 5']].freeze
    Example_hash = { name: 'Fred', salary: 10, department: :Engineering }.freeze
    Example_tuples = [Example_hash, { name: 'Bob', salary: 11 }].freeze
    Example_department = { department: :Engineering, manager: 'Bob' }.freeze
    Example_database = { employees: Example_tuples, departments: Example_department }.freeze
  end # Examples
end # Connectivity

class NestedArrayType < Connectivity
  module ClassMethods
    def children?(node)
      children_if_exist?(node, :to_a)
    end # children
  end # ClassMethods
  extend Connectivity::ClassMethods
  extend ClassMethods
  module Assertions
    module ClassMethods
      def assert_pre_conditions(message = '')
        message += "In assert_pre_conditions, self=#{inspect}"
        assert_equal(self, NestedArrayType, message)
        assert_includes(ancestors, NestedArrayType)
        assert_equal(ancestors, [NestedArrayType, NestedArrayType::Examples])
        assert_equal(included_modules, [NestedArrayType::Examples], message)
        assert_empty(methods(false), message)
        assert_empty(methods(false), message)
      end # assert_pre_conditions

      def assert_post_conditions(message = '')
        message += "In assert_post_conditions, self=#{inspect}"
        assert_equal(self, NestedArrayType, message)
        assert_equal(NestedArrayType.ancestors, [NestedArrayType, NestedArrayType::Examples])
        assert_equal(NestedArrayType.included_modules, [NestedArrayType::Examples], message)
        assert_empty(NestedArrayType.methods(false), message)
        assert_empty(NestedArrayType::ClassMethods.methods(false), message)
      end # assert_post_conditions
    end # ClassMethods
  end # Assertions
  extend Assertions::ClassMethods
  module Examples
  end # Examples
  include Examples
end # NestedArrayType
class HashConnectivity < Connectivity
end # HashConnectivity

class Node
  include Virtus.model
  attribute :node, Object # root
  attribute :graph_type, Connectivity
  def parent_at(*params)
    path = GraphPath.new(*params)
    if path.parent_index.nil? || path.parent_index == [] || path.parent_index == [nil]
      parent = @node
    else
      parent = at(path.parent_index)
    end # if
  end # parent_at

  # [] is already taken
  def at(*params)
    path = GraphPath.new(*params)
    parent = parent_at(path)
    if path.child_index.nil?
      parent
    else
      parent[path.child_index]
    end # if
  end # at
  # Apply block to each node (branch & leaf).
  # Nesting structure remains the same.
  # Array#map will only process the top level Array.
  module Examples
    Nested_array_root = NestedArrayType.ref(Connectivity::Examples::Nested_array)
  end # Examples
  include Examples
end # node

module Graph # see http://rubydoc.info/gems/gratr/0.4.3/file/README
  module Constants
    Identity_map = proc { |e, _depth, _terminal| e.node }
    Trace_map = proc { |e, depth, terminal| [e.node, depth, terminal] }
    Leaf_map = proc { |e, _depth, terminal| (terminal.nil? || terminal ? e : nil) }
  end # Constants
  include Constants
end # Graph
module DAG
  include Graph
  include Graph::Constants
end # DAG
module Forest
  include DAG
end # Forest
module Leaf
  include Graph
  def nonterminal?(_children_method_name = :to_a)
    true # end recursion
  end # nonterminal?
end # Leaf
module Tree
  include DAG
  module Constants
    include Graph::Constants
  end # Constants
  include Constants
  # Apply block to each non-leaf or branching node
  # Provides a postfix walk
  # Two passes:
  # 1) Recursively visit descendants
  # 2) Visit branching nodes (Arrays)
  # Desirable since result tree is constructed bottom-up
  # Descendants have the block applied before they are reassembled into a tree.
  # Branching node block can take into account changes in subtrees.

  def map_branches(depth = 0)
    visited_subtrees = map do |sub_tree|
      if sub_tree.respond_to?(:expressions)
        self.class.new(sub_tree).map_branches(depth + 1) { |p| yield(p, depth) }
      else
        sub_tree
      end # if
    end
    yield(visited_subtrees)
  end # map_branches
  module Examples
    include Constants
    Trivial_array = [0].freeze
    Flat_array = [0].freeze
    Flat_hash = { cat: :fish }.freeze
  end # Examples
  include Examples
end # Tree
