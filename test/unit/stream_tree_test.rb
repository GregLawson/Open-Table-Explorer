###########################################################################
#    Copyright (C) 2014-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/stream_tree.rb'
class StreamTreeTest < TestCase
  # include DefaultTests
  # include RailsishRubyUnit::Executable.model_class?::Examples
  include GraphPath::Examples
  include Tree::Examples
  include Connectivity::Examples
  require 'rgl/adjacency'
  require 'rgl/dot'
  def test_rgl_readme
    dg = RGL::DirectedAdjacencyGraph[1, 2, 2, 3, 2, 4, 4, 5, 6, 4, 1, 6]
    # Use DOT to visualize this graph:
    dg.write_to_graphic_file('jpg')
    assert_equal(true, dg.directed?)
    assert_equal([5, 6, 1, 2, 3, 4], dg.vertices)
    assert_equal(true, dg.has_vertex?(4))
    assert_equal(false, dg.has_vertex?(Object))
    assert_equal('(1-2)(1-6)(2-3)(2-4)(4-5)(6-4)', dg.edges.sort.to_s)
    assert_equal('(1=2)(1=6)(2=3)(2=4)(5=4)(6=4)', dg.to_undirected.edges.sort.to_s)

    # Add inverse edge (4-2) to directed graph:
    dg.add_edge 4, 2
    # (4-2) == (2-4) in the undirected graph:

    assert_equal('(1=2)(1=6)(2=3)(2=4)(5=4)(6=4)', dg.to_undirected.edges.sort.to_s)

    # (4-2) != (2-4) in directed graphs:

    assert_equal('(1-2)(1-6)(2-3)(2-4)(4-2)(4-5)(6-4)', dg.edges.sort.to_s)

    assert_equal(true, dg.remove_edge(4, 2))

    # Topological sort is implemented as an iterator:

    require 'rgl/topsort'
    assert_equal([1, 2, 3, 6, 4, 5], dg.topsort_iterator.to_a)

    # A more elaborated example showing implicit graphs:

    require 'rgl/implicit'
    def module_graph
      RGL::ImplicitGraph.new do |g|
        g.vertex_iterator do |b|
          ObjectSpace.each_object(Module, &b)
        end
        g.adjacent_iterator do |x, b|
          x.ancestors.each do |y|
            b.call(y) unless x == y || y == Kernel || y == Object
          end
        end
        g.directed = true
      end
    end
    # This function creates a directed graph, with vertices being all loaded modules:

    g = module_graph
    # We only want to see the ancestors of {RGL::AdjacencyGraph}:

    require 'rgl/traversal'
    tree = g.bfs_search_tree_from(RGL::AdjacencyGraph)
    # Now we want to visualize this component of g with DOT. We therefore create a subgraph of the original graph, using a filtered graph:

    g = g.vertices_filtered_by { |v| tree.has_vertex? v }
    g.write_to_graphic_file('jpg')
  end # rgl_readme

  def test_GraphPath_initialize
    assert_equal(GraphPath.new(nil), Root_path)
    assert_equal(GraphPath.new(nil), [])
    assert_equal(GraphPath.new, [])
    assert_equal(First_son, GraphPath.new(First_son))
    assert_equal(GraphPath.new(First_son), First_son, First_son.inspect)
    assert_equal(GraphPath.new(First_son[0], First_son[1]), First_son, First_son.inspect)
    assert_equal([[], 0], GraphPath.new(First_son[0], First_son[1]), First_son.inspect)
    assert_equal(GraphPath.new(First_grandson), First_grandson, First_grandson.inspect)
  end # initialize

  def test_deeper
  end # deeper

  def test_parent_index
    assert_equal([], Root_path.parent_index, Root_path.inspect)
    assert_equal(First_son, GraphPath.new(First_son), First_son.inspect)
    assert_equal(Root_path, GraphPath.new(First_son)[0], First_son.inspect)
    assert_equal(Root_path, GraphPath.new(GraphPath.new(First_son)[0]), First_son.inspect)
    assert_equal(Root_path, GraphPath.new(First_son).parent_index, First_son.inspect)
    assert_equal([], GraphPath.new(First_son).parent_index, First_son.inspect)
    assert_equal([], GraphPath.new(First_son)[0], First_son.inspect)
    assert_equal([], GraphPath.new(First_son).parent_index, First_son.inspect)
  end # parent_index

  def test_child_index
    assert_equal(0, GraphPath.new(First_son).child_index, GraphPath.new(First_son).inspect)
    assert_equal(Root_path.child_index, nil, Root_path.inspect)
  end # child_index

  def test_Constants
    assert_equal(Root_path, GraphPath.new(nil))
  end # Constants

  # Connectivity
  def test_ref
    assert_instance_of(Node, ref)
  end # ref

  def test_square_brackets(*params)
  end # square_brackets

  def test_children?
    assert_empty(nil)
    assert(nil.to_a.empty?) # allows uniform testing of empty Array and nil
    assert_equal(Nested_array, Connectivity.children?(Nested_array))
    assert_equal(Son_nested_array, Connectivity.children?(Son_nested_array), 'Son_nested_array = ' + Son_nested_array.inspect)
    assert_equal(nil, Connectivity.children_if_exist?(Grandson_nested_array, :to_a), 'Grandson_nested_array = ' + Grandson_nested_array.inspect)
  end # children?

  def test_nonterminal?
    assert_respond_to(Nested_array, Children_method_name)
    assert_equal(Inspect_node_root, Node_format.call(Nested_array))
    assert_equal(1, Children_nested_array.size)
    assert_equal(true, NestedArrayType.nonterminal?(Nested_array), NestedArrayType.inspect)
    assert_respond_to(Son_nested_array, Children_method_name)
    assert_instance_of(Array, Grandchildren_nested_array)
    assert_equal(1, Grandchildren_nested_array.size)
    assert_equal(nil, NestedArrayType.nonterminal?(Grandson_nested_array), Grandson_nested_array.inspect)
    assert_equal(true, NestedArrayType.nonterminal?(Son_nested_array), Son_nested_array.inspect)
  end # nonterminal?

  def test_each_pair
  end # each_pair

  def test_map_pair
  end # map_pair

  def test_inspect_node
    assert_equal(Inspect_node_root, NestedArrayType.inspect_node(Nested_array))
    assert_equal('[2, [3], 4]', NestedArrayType.inspect_node(Son_nested_array))
    assert_equal('3', NestedArrayType.inspect_node(Grandson_nested_array))
    assert_match(NestedArrayType.inspect_node(Nested_array), Tree_node_root)
  end # inspect_node

  def test_map_recursive
    depth = 0
    visit_proc = Tree_node_format
    node = NestedArrayType.ref(Nested_array)
    refute_nil(node)
    refute_nil(node.graph_type, node.inspect)
    assert_respond_to(node.graph_type, :inspect_node)
    assert_equal(Tree_node_root, visit_proc.call(NestedArrayType.ref(Nested_array), depth, false))
    assert_equal(1, Children_nested_array.size)
    assert_respond_to(Son_nested_array, Children_method_name)
    assert_instance_of(Array, Grandchildren_nested_array)
    assert_equal(1, Grandchildren_nested_array.size)
    refute_respond_to(Grandson_nested_array, Children_method_name)
    assert_equal('3', NestedArrayType.inspect_node(Grandson_nested_array))

    assert_equal('[2, [3], 4]', NestedArrayType.inspect_node(Son_nested_array), Son_nested_array.inspect)
    assert_equal(nil, NestedArrayType.nonterminal?(Grandson_nested_array), Grandson_nested_array.inspect) # termination condition
    assert_equal(Grandson_nested_array_map, NestedArrayType.map_recursive(Grandson_nested_array, depth = 2, &Tree_node_format))
    assert_equal(Son_nested_array_map, NestedArrayType.map_recursive(Son_nested_array, depth = 1, &Tree_node_format))
    assert_equal(Nested_array_map, NestedArrayType.map_recursive(Nested_array, &Tree_node_format))
  end # map_recursive

  def test_inspect_nonterminal?
    assert_equal(true, NestedArrayType.nonterminal?(Nested_array), NestedArrayType.inspect)
    assert_equal('nonterminal', NestedArrayType.inspect_nonterminal?(Nested_array), NestedArrayType.inspect)
    assert_equal(true, NestedArrayType.nonterminal?(Son_nested_array), Son_nested_array.inspect)
    assert_equal('nonterminal', NestedArrayType.inspect_nonterminal?(Son_nested_array), Son_nested_array.inspect)
    assert_equal(nil, NestedArrayType.nonterminal?(Grandson_nested_array), Grandson_nested_array.inspect)
    assert_equal(true, NestedArrayType.leaf_typed?, Grandson_nested_array.inspect)
    assert_equal('leaf typed', NestedArrayType.inspect_nonterminal?(Grandson_nested_array), Grandson_nested_array.inspect)
  end # inspect_nonterminal?

  def test_inspect_recursive
    assert_equal(Grandson_nested_array_map, NestedArrayType.map_recursive(Grandson_nested_array, depth = 2, &Tree_node_format))
    assert_equal(Son_nested_array_map, NestedArrayType.map_recursive(Son_nested_array, depth = 1, &Tree_node_format))
    assert_equal(Nested_array_map, NestedArrayType.map_recursive(Nested_array, &Tree_node_format))
    assert_equal((Nested_array_map.flatten.map { |s| s + "\n" }).join, NestedArrayType.inspect_recursive(Nested_array, &Tree_node_format), NestedArrayType.inspect_recursive(Nested_array, &Tree_node_format))
    assert_equal((Nested_array_map.flatten.map { |s| s + "\n" }).join, NestedArrayType.inspect_recursive(Nested_array), NestedArrayType.inspect_recursive(Nested_array))

    #	assert_equal('ab # ' + Nested_array_map + "\n", Sequence_example.inspect_recursive(&Mx_format))
    #	assert_equal('a # ' + Nested_array_map + "\n", Alternative_example.inspect_recursive(&Mx_format))
  end # inspect_recursive

  def test_Assertions
    Connectivity.assert_pre_conditions
    Connectivity.assert_post_conditions
  end # Assertions

  def test_each_pair
    collect = []
    NestedArrayType.each_pair(Example_array) { |key, value| collect << [key, value] }
    assert_equal(collect, [[0, 1], [1, 2], [2, 3]])
  end # each_pair

  def test_map_pair_Array
    tree = Flat_array
    idenity_map = Array::Constants::Identity_map_pair
    assert_includes(NestedArrayType.methods, :each_pair)
    assert_includes(NestedArrayType.methods, :map_pair)
    assert_equal(tree, NestedArrayType.map_pair(tree, &idenity_map))
  end # map_pair

  def test_NestedArrayType_Assertions
    assert_includes(NestedArrayType.methods, :each_pair)
    assert_includes(NestedArrayType.methods, :each_pair)
    assert_includes(NestedArrayType.methods, :map_pair)
    assert_includes(NestedArrayType.methods, :children?)
    assert_empty(NestedArrayType::ClassMethods.methods(false))
    assert_empty(NestedArrayType::ClassMethods.methods(false))
    assert_includes(NestedArrayType::ClassMethods.instance_methods(false), :each_pair)
    #	assert_includes(NestedArrayType::ClassMethods.instance_methods, :ref)
    assert_equal(NestedArrayType.instance_methods, [])

    assert_includes(NestedArrayType.methods, :children?)
    assert_equal(NestedArrayType.instance_methods, [])
    assert_equal(NestedArrayType.methods(false), [])
    assert_includes(NestedArrayType.methods, :each_pair)
    NestedArrayType.assert_pre_conditions
    NestedArrayType.assert_post_conditions

    assert_includes(Connectivity.methods, :ref)

    assert_includes(NestedArrayType.methods, :ref)
  end # Assertions

  def test_parent_at
    assert_equal(Node::Examples::Nested_array_root.parent_at(nil, 0), Nested_array)
    assert_equal(Node::Examples::Nested_array_root.parent_at(nil), Nested_array)
    assert_equal(Node::Examples::Nested_array_root.parent_at([nil, 0]), Nested_array)
  end # parent_at

  def test_at
    assert_includes(Node::Examples::Nested_array_root.methods, :at, Node::Examples::Nested_array_root.inspect)
    explain_assert_respond_to(Node::Examples::Nested_array_root, :at, Node::Examples::Nested_array_root.inspect)
    assert_equal(GraphPath.new(*Root_path), Root_path)
    path = GraphPath.new(Root_path)
    assert_empty(Root_path.parent_index)
    assert_empty(path.parent_index)
    assert(path.parent_index == [])
    assert_equal(Node::Examples::Nested_array_root.at(nil, 0), Nested_array[0])
    assert_equal(Node::Examples::Nested_array_root.at(Root_path), Nested_array)
    #	assert_equal(Nested_array, Node::Examples::Nested_array_root.at(Root_path))
    assert_equal(0, GraphPath.new(First_son).child_index, First_son.inspect)
    #	assert_equal(Son_nested_array, Node::Examples::Nested_array_root.at(First_son), First_son.inspect)
    #	assert_equal(Grandson_nested_array, Node::Examples::Nested_array_root.at(First_grandson), First_grandson.inspect)
  end # at

  def test_Node_Examples
    assert_includes(NestedArrayType.methods, :ref)
    NestedArrayType.ref(Connectivity::Examples::Nested_array)
  end # test_node_Examples

  def test_Node_format
    assert_equal(Inspect_node_root, NestedArrayType.inspect_node(Nested_array))
    assert_equal(Inspect_node_root, NestedArrayType.inspect_node(Nested_array, &Node_format))
    #	assert_match(/cat/, Tree_node_format.call('cat', depth=0, false))
  end # Node_format

  def test_map_recursive_content
    assert_equal([[0], [0]], NestedArrayType.map_recursive(Trivial_array, &Identity_map))
    assert_equal([Trivial_array, Trivial_array], NestedArrayType.map_recursive(Trivial_array, &Identity_map))
    #	assert_equal([Flat_hash, NestedArrayType.values], Flat_hash.map_recursive(Flat_array, &Identity_map))
  end # content

  def test_map_recursive_depth
    assert_equal([[[0], 0, false], [[0, 1, nil]]], NestedArrayType.map_recursive(Flat_array, &Trace_map))
    #	assert_equal([Flat_array], NestedArrayType.map_recursive(Flat_array, &Leaf_map).compact)
  end # test_map_recursive_simple_block

  def test_values
    assert_equal(Example_array, Example_array.values)
  end # values

  def test_keys
    assert_equal([0, 1, 2], Example_array.keys)
  end # keys

  def test_to_hash
    assert_equal(Example_array, Example_array.to_hash.to_a.values)
  end # to_hash

  def test_each_with_index
  end # each_with_index

  def test_map_pair_Hash
    tree = Flat_hash
    idenity_map = tree.class::Constants::Identity_map_pair
    assert_equal(tree, tree.map_pair(&idenity_map))
  end # map_pair

  def test_hash_minus
    assert_equal({}, {} - {})
    assert_equal({}, { cat: 1 } - { cat: 1 })
    assert_equal({ cat: 1 }, { cat: 1 } - { dog: 1 })
    assert_equal({ cat: 1 }, { cat: 1 } - { cat: 2 })
    assert_equal({ cat: 1 }, { cat: 1, dog: 3 } - { cat: 2, dog: 3 })
    assert_equal({ cat: 1, dog: { fish: 5 } }, { cat: 1, dog: { fish: 5, bird: 6 } } - { cat: 2, dog:  { bird: 6 } })
  end # -

  def test_operator
    assert_equal({}, {}.operator({}))
    assert_equal({ lhs_key: :lhs_value }, { lhs_key: :lhs_value }.operator(rhs_key: :rhs_value) { |key, lhs, _rhs| lhs[key] })
    assert_equal({ common_key: :lhs_value }, { common_key: :lhs_value }.operator(common_key: :rhs_value) { |key, lhs, _rhs| lhs[key] })
    assert_equal({ common_key: :rhs_value }, { common_key: :lhs_value }.operator(common_key: :rhs_value) { |key, _lhs, rhs| rhs[key] })
    assert_equal({}, { lhs_key: :lhs_value }.operator(rhs_key: :rhs_value) { |key, _lhs, rhs| rhs[key] })

    operator_lambda = lambda do |key, lhs, rhs|
      assert_instance_of(Symbol, key)
      assert_instance_of(Hash, lhs)
      assert_instance_of(Hash, rhs)
      refute_nil(lhs[key])
      if rhs[key].nil? || lhs[key] != rhs[key]
        lhs[key]
      end # if
    end # lambda
    assert_equal({}, {}.operator({}, &operator_lambda))

    assert_equal({ cat: 1 }, { cat: 1 }.operator({ dog: 1 }, &operator_lambda))
    assert_equal({ cat: 1 }, { cat: 1 }.operator({ cat: 2 }, &operator_lambda))
    assert_equal({ cat: 1 }, { cat: 1, dog: 3 }.operator({ cat: 2, dog: 3 }, &operator_lambda))
    assert_equal({ fish: 5 }, { fish: 5, bird: 6 }.operator({ bird: 6 }, &operator_lambda))
    assert_equal({ cat: 1, dog: { fish: 5 } }, { cat: 1, dog: { fish: 5, bird: 6 } }.operator({ cat: 2, dog:  { bird: 6 } }, &operator_lambda))
    assert_equal({ cat: 1 }, { cat: 1 }.operator({ dog: 2 }, &operator_lambda))
    assert_equal({ cat: 1 }, { cat: 1 }.operator({ dog: 1 }, &operator_lambda))

    assert_equal({ cat: 1 }, { cat: 1 }.operator(dog: 2) { |key, lhs, _rhs| lhs[key] })
    assert_equal({ cat: nil }, { cat: 1 }.operator(dog: 1) { |key, _lhs, rhs| rhs[key] })
    assert_equal({ cat: 1 }, { cat: 1 }.operator(dog: 1) { |key, lhs, rhs| lhs[key] - rhs[key] })
    assert_equal({ cat: 1 }, { cat: 1 }.operator(cat: 2) { |key, lhs, rhs| lhs[key] - rhs[key] })
    assert_equal({ cat: 1 }, { cat: 1, dog: 3 }.operator(cat: 2, dog: 3) { |key, lhs, rhs| lhs[key] - rhs[key] })
    assert_equal({ cat: 1, dog: { fish: 5 } }, { cat: 1, dog: { fish: 5, bird: 6 } }.operator(cat: 2, dog:  { bird: 6 }) { |key, lhs, rhs| lhs[key] - rhs[key] })
    assert_equal({ cat: 0 }, { cat: 1 }.operator({ cat: 1 }, &operator_lambda))
  end # operator

  def test_intersection
    assert_equal({}, {} & {})
    assert_equal({ cat: 1 }, { cat: 1 } & { cat: 1 })
    assert_equal({}, { cat: 1 } & { dog: 1 })
    assert_equal({ cat: 1 }, { cat: 1 } & { cat: 2 })
    assert_equal({ dog: { bird: 6 } }, { cat: 1, dog: { fish: 5, bird: 6 } } & { cat: 2, dog:  { bird: 6 } })
  end # intersection

  def test_enumerate_single
    atom = /5/
    single = atom.enumerate_single(:map) { |e| e }
    refute_nil(single)
    assert_equal(5, 5.enumerate_single(:map) { |e| e })
    assert_equal(5, 5.enumerate_single(:select) { |e| e == 5 })
    assert_equal(nil, 5.enumerate_single(:select) { |e| e == 6 })
    assert_equal(false, 5.enumerate_single(:all?) { |e| e == 6 })
    assert_equal(true, 5.enumerate_single(:all?) { |e| e == 5 })
  end # enumerate_single

  def test_enumerate
    atom = [/5/]
    single = atom.enumerate(:map) { |e| e }
    refute_nil(single)
    assert_equal([5], [5].enumerate(:map) { |e| e })
    assert_equal([5], [5].enumerate(:select) { |e| e == 5 })
    assert_equal([], [5].enumerate(:select) { |e| e == 6 })
    assert_equal(false, [5].enumerate(:all?) { |e| e == 6 })
    assert_equal(true, [5].enumerate(:all?) { |e| e == 5 })
  end # enumerate
end # StreamTree
