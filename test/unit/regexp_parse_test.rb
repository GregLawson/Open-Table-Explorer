###########################################################################
#    Copyright (C) 2010-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment'
require_relative '../../app/models/unit.rb'
require_relative '../../app/models/test_environment_test_unit.rb'
#require_relative '../../app/models/regexp_parse.rb'
require_relative '../assertions/regexp_parse_assertions.rb'
class RegexpParseTest < TestCase
  # include DefaultTests
  include RegexpParseType::Examples
  include Connectivity::Examples
  # include RegexpParse::Examples
  include Regexp::Expression::Base::Constants
  # include RegexpToken::Constants
  # include RegexpParse::Assertions
  # include NestedArray::Examples
  include Graph::Constants
  include Regexp::Expression::Base::Examples
  def test_expression_class_symbol?
    node = Literal_a
    assert_equal('Regexp::Expression::Root', node.class.name)
    assert_equal(:Root, RegexpParseType.expression_class_symbol?(node))
  end # expression_class_symbol?

  def test_Node_format
    assert_equal(Inspect_node_root, RegexpParseType.inspect_node(Literal_a))
    #	assert_equal(Inspect_node_root, Literal_a.inspect_node(&Node_format))
  end # Node_format

  def test_Mx_format
    assert_match(Tree_node_root, Mx_format.call(RegexpParseType.ref(Literal_a), 0, false))
    assert_equal(Mx_node_root, Mx_format.call(RegexpParseType.ref(Literal_a), depth = 0, false))
    assert_equal(Mx_node_options, Mx_format.call(RegexpParseType.ref(Son_a), depth = 1, false))
    assert_equal(Mx_node_a, Mx_format.call(RegexpParseType.ref(Grandson_a), depth = 2, true))
    assert_equal([Mx_node_root, Mx_node_options, Mx_node_a].map { |s| s + "\n" }.join, RegexpParseType.inspect_recursive(Literal_a, &Mx_format))
  end # Mx_format

  def test_inspect_node
    #	assert_equal(Inspect_node_root, RegexpParseType.inspect_node(Literal_a, &Node_format))
    assert_equal(Inspect_node_root, RegexpParseType.inspect_node(Literal_a))
    assert_equal(Node_options, RegexpParseType.inspect_node(Son_a))
    assert_equal(Node_a, RegexpParseType.inspect_node(Grandson_a))
    assert_match(RegexpParseType.inspect_node(Literal_a), Tree_node_root)
    #	assert_match(RegexpParseType.inspect_node(Literal_a), &Node_format), Tree_node_root)
    node = RegexpParseType.ref(Literal_a)
    #	assert_equal('nonterminal', node.graph_type.inspect_nonterminal?(node.node))
  end # inspect_node

  def test_Node_format
    assert_equal(Inspect_node_root, RegexpParseType.inspect_node(Literal_a))
    #	assert_equal(Inspect_node_root, Literal_a.inspect_node(&Node_format))
  end # Node_format

  def test_inspect_recursive
    assert_equal(Grandson_a_map, RegexpParseType.map_recursive(Grandson_a, depth = 2, &Tree_node_format))
    assert_equal(Son_a_map, RegexpParseType.map_recursive(Son_a, depth = 1, &Tree_node_format))
    assert_equal(Literal_a_map, RegexpParseType.map_recursive(Literal_a, &Tree_node_format))
    assert_equal((Literal_a_map.flatten.map { |s| s + "\n" }).join, RegexpParseType.inspect_recursive(Literal_a, &Tree_node_format), RegexpParseType.inspect_recursive(Literal_a, &Tree_node_format))
    assert_equal((Literal_a_map.flatten.map { |s| s + "\n" }).join, RegexpParseType.inspect_recursive(Literal_a), RegexpParseType.inspect_recursive(Literal_a))

    #	assert_equal('ab # ' + Literal_a_map + "\n", Sequence_example.inspect_recursive(&Mx_format))
    #	assert_equal('a # ' + Literal_a_map + "\n", Alternative_example.inspect_recursive(&Mx_format))
  end # inspect_recursive

  def test_Mx_format
    assert_match(Tree_node_root, Mx_format.call(RegexpParseType.ref(Literal_a), 0, false))
    assert_equal(Mx_node_root, Mx_format.call(RegexpParseType.ref(Literal_a), depth = 0, false))
    assert_equal(Mx_node_options, Mx_format.call(RegexpParseType.ref(Son_a), depth = 1, false))
    assert_equal(Mx_node_a, Mx_format.call(RegexpParseType.ref(Grandson_a), depth = 2, true))
    assert_equal([Mx_node_root, Mx_node_options, Mx_node_a].map { |s| s + "\n" }.join, RegexpParseType.inspect_recursive(Literal_a, &Mx_format))
  end # Mx_format

  def test_Tree_node_format
    node = RegexpParseType.ref(Literal_a)
    assert_equal('nonterminal', node.graph_type.inspect_nonterminal?(node.node))
    assert_equal(Inspect_node_root, node.graph_type.inspect_node(node.node))
    #	assert_equal(Inspect_node_root, RegexpParseType.inspect_node(node, &Node_format))
    assert_equal(Tree_node_root, Tree_node_format.call(node, depth = 0, false))
    assert_equal(Tree_node_options, Tree_node_format.call(RegexpParseType.ref(Son_a), depth = 1, false))
    assert_equal(Tree_node_a, Tree_node_format.call(RegexpParseType.ref(Grandson_a), depth = 2, true))
    assert_equal('terminal[1], ' + Inspect_node_root, Tree_node_format.call(RegexpParseType.ref(Literal_a), depth = 1, true))
    assert_equal('terminal[2], ' + Inspect_node_root, Tree_node_format.call(RegexpParseType.ref(Literal_a), depth = 2, nil))
    assert_equal('unknown[3], ' + Inspect_node_root, Tree_node_format.call(RegexpParseType.ref(Literal_a), depth = 3, 1)) # unknown
  end # Tree_node_format

  def test_raw_capture?
    assert_equal(Literal_a_map, RegexpParseType.map_recursive(Literal_a, &Tree_node_format))
    #	assert_equal([], RegexpParseType.map_recursive(Literal_a, :expressions){|e, depth, terminal| [e.quantifier, e.to_s]}, Literal_a_map)
    assert_equal('*', Grandson_a.quantifier.text)
    assert_equal('*', Grandson_a.quantifier.to_s)
    e = Grandson_a
    assert_equal(-2, -1 - e.quantifier.to_s.size)
    assert_equal('a*', Grandson_a.to_s)
    assert_equal('a', Grandson_a.to_s[0..-2])
    assert_equal('a', Grandson_a.to_s[0..-1 - e.quantifier.to_s.size], Grandson_a.inspect)
    assert_instance_of(Array, Literal_a.raw_capture?('a'))
    assert_instance_of(Array, Regexp::Parser.parse(/a*/.to_s, 'ruby/1.8').raw_capture?('aa'))
    assert_instance_of(Array, Regexp::Parser.parse(/a*b/.to_s, 'ruby/1.8').raw_capture?('aab'))
  end # raw_capture?

  def test_Constants
  end # Constants

  def test_nonterminal?
    assert_respond_to(Literal_a, Children_method_name)
    #	assert_equal(Inspect_node_root, Node_format.call(Literal_a))
    assert_equal(1, Children_a.size)
    assert_equal(true, RegexpParseType.nonterminal?(Literal_a), Literal_a.inspect)
    assert_respond_to(Son_a, Children_method_name)
    assert_instance_of(Array, Grandchildren_a)
    assert_equal(1, Grandchildren_a.size)
    assert_equal(true, RegexpParseType.nonterminal?(Son_a), Son_a.inspect)
    assert_equal(nil, RegexpParseType.nonterminal?(Grandson_a), Grandson_a.inspect)
  end # nonterminal?

  def test_map_recursive
    assert_includes(Connectivity::Examples.constants, :Tree_node_format)
    assert_includes(RegexpParseTest.constants, :Tree_node_format)
    depth = 0
    visit_proc = Tree_node_format
    assert_respond_to(Literal_a, Children_method_name)
    assert_equal(Tree_node_root, Tree_node_format.call(RegexpParseType.ref(Literal_a), depth = 0, false))
    assert_equal(Tree_node_root, visit_proc.call(RegexpParseType.ref(Literal_a), depth, false))
    assert_equal(1, Children_a.size)
    assert_respond_to(Son_a, Children_method_name)
    assert_instance_of(Array, Grandchildren_a)
    assert_equal(1, Grandchildren_a.size)
    refute_respond_to(Grandson_a, Children_method_name)
    assert_equal(Node_a, RegexpParseType.inspect_node(Grandson_a))

    assert_equal(Node_options, RegexpParseType.inspect_node(Son_a), Son_a.inspect)
    assert_equal(nil, RegexpParseType.nonterminal?(Grandson_a), Grandson_a.inspect) # termination condition
    assert_equal(Grandson_a_map, RegexpParseType.map_recursive(Grandson_a, depth = 2, &Tree_node_format))
    assert_equal(Son_a_map, RegexpParseType.map_recursive(Son_a, depth = 1, &Tree_node_format))
    assert_equal(Literal_a_map, RegexpParseType.map_recursive(Literal_a, &Tree_node_format))
  end # map_recursive

  def test_Examples
  end # Examples

  # Example from readme
  def test_readme
    regex = /a?(b)*[c]+/m

    # using #to_s on the Regexp object to include options
    root = Regexp::Parser.parse(regex.to_s, 'ruby/1.8')

    assert_equal(root.multiline?, true)
    assert_equal(root.case_insensitive?, false)

    # simple tree walking method
    def walk(e, depth = 0)
      puts "#{'  ' * depth}> #{e.class}"
      termination_condition = e.instance_of?(Regexp::Expression::Literal) # no subexpressions
      #	termination_condition ||= e.expressions.empty?
      termination_condition = e.terminal?
      if termination_condition
      else
          e.each { |s| walk(s, depth + 1) }
      end
    end # walk
    assert_equal('Regexp::Expression::Root', root.class.name)
    assert_instance_of(Regexp::Parser::Root, root)
    assert_includes(root.methods, :expressions)
    puts 'root=' + root.inspect
    walk(root)
    # output
    #	> Regexp::Expression::Root
    #	  > Regexp::Expression::Literal
    #	  > Regexp::Expression::Group::Capture
    #	    > Regexp::Expression::Literal
    #	  > Regexp::Expression::CharacterSet
  end # readme

  def test_Base_inspect
    root = Regexp::Parser.parse(/a/.to_s, 'ruby/1.8')
    #	assert_equal([], RegexpParseType.map_recursive(root, &Tree_node_format))
    #	assert_equal([], root.map_recursive(:expressions){|terminal, e, depth| "#{e.class}(:#{e.type}, :#{e.token}, '#{e.text}')" })
  end # inspect

  # RegexpParse.assert_pre_conditions #verify class
  def test_initialize
    regexp_string = ['.', '*']
    assert_kind_of(Array, regexp_string)
    assert_instance_of(Array, regexp_string)
    regexp_parse = RegexpParse.new(regexp_string)
    assert_equal(['.', '*'], regexp_string.to_a, "regexp_string=#{regexp_string.inspect}, regexp_string.to_a=#{regexp_string.to_a.inspect}")
    assert_equal('.*', regexp_string.join, "regexp_string=#{regexp_string.inspect}, regexp_string.join=#{regexp_string.join.inspect}")
    assert_equal('.*', regexp_parse.regexp_string, "regexp_parse=#{regexp_parse.inspect}")
    assert_equal('.*', regexp_parse.regexp_string.to_s)
    assert_equal(['.', '*'], regexp_parse.parse_tree)
    regexp_parse.assert_invariant
    assert_equal('@regexp_string=".*", @parse_tree=[".", "*"], @tokenIndex=-1', regexp_parse.inspect, "regexp_parse=#{regexp_parse.inspect}")
    assert_equal('@regexp_string=".*", @parse_tree=[".", "*"], @tokenIndex=-1', RegexpParse.new(['.', '*']).inspect, "RegexpParse.new(['.', '*'])=#{RegexpParse.new(['.', '*']).inspect}")
    regexp_string = 'K.*C'
    test_tree = RegexpParse.new(regexp_string)
    assert_equal(regexp_string, test_tree.to_s)
    refute_nil(test_tree.regexp_string)
    refute_nil(RegexpParse.new(test_tree.rest).to_s)
    #	refute_nil(RegexpParse.new(nil))
    assert_instance_of(NestedArray, RegexpParse.new(['.', '*']).parse_tree)
    assert_instance_of(NestedArray, RegexpParse.new(CONSTANT_PARSE_TREE).parse_tree)
    assert_instance_of(NestedArray, RegexpParse.new(/.*/).parse_tree)
    assert_instance_of(NestedArray, RegexpParse.new('.*').parse_tree)
    assert_instance_of(RegexpParse, Parenthesized_parse)
    Parenthesized_parse.assert_post_conditions
    CONSTANT_PARSE_TREE.assert_post_conditions
    KC_parse.assert_post_conditions
    Rows_parse.assert_post_conditions
    RowsEdtor2.assert_post_conditions
    KCET_parse.assert_post_conditions
    assert_equal(2, RegexpParse.new('.*').parse_tree.size)
    assert_equal(['.', '*'], RegexpParse.new('.*').parse_tree)
    #	assert_equal(Nested_Test_Array, NestedArray.new(Nested_Test_Array).map_recursive(&NestedArray::Examples::Echo_proc))
    #	assert_equal(Nested_Test_Array, NestedArray.new(Nested_Test_Array).map_branches(&NestedArray::Examples::Echo_proc))
  end # initialize

  def test_inspect
    inspect_string = '@regexp_string=".*", @parse_tree=[".", "*"], @tokenIndex=-1'
    assert_equal(inspect_string, RegexpParse.new('.*').inspect)
    assert_equal(inspect_string, Dot_star_parse.inspect)
  end # inspect

  def test_regexp_error
    assert_nothing_raised { RegexpParse.regexp_error('(') }
  end # regexp_error

  def test_equal_operator
    rhs = Dot_star_parse
    lhs = RegexpParse.new('.*')
    assert_includes(lhs.methods, :==)

    assert_equal(rhs, lhs)
  end # equal_operator

  def test_equal
    rhs = Dot_star_parse
    lhs = RegexpParse.new('.*')
    assert_includes(lhs.methods, :eql?)

    assert(lhs.eql?(rhs))
    assert_equal(rhs, lhs)
  end # equal

  def test_compare
    rhs = Dot_star_parse
    lhs = RegexpParse.new('.*')
    compare = rhs <=> lhs
    assert_equal(0, compare)
    assert_equal(['.', '*'], ['.', '*'])
    assert(lhs.eql?(rhs))
    assert_equal(rhs, lhs)
  end # compare

  def test_RegexpParse_promotable
    assert(RegexpParse.promotable?(/.*/))
    assert(RegexpParse.promotable?('.*'))
    assert(RegexpParse.promotable?(['.', '*']))
  end # RegexpParse.promotable

  def test_RegexpParse_promote
    assert_equal(Dot_star_parse, RegexpParse.promote(Dot_star_parse))
    assert_equal(Dot_star_parse, RegexpParse.promote('.*'))
    assert_equal('@regexp_string=".*", @parse_tree=[".", "*"], @tokenIndex=-1', RegexpParse.new(['.', '*']).inspect, "RegexpParse.new(['.', '*'])=#{RegexpParse.new(['.', '*']).inspect}")
    assert_equal('@regexp_string=".*", @parse_tree=[".", "*"], @tokenIndex=-1', RegexpParse.promote(['.', '*']).inspect, "RegexpParse.promote(['.', '*'])=#{RegexpParse.promote(['.', '*']).inspect}")
    assert_equal(Dot_star_parse, RegexpParse.promote(['.', '*']), "Dot_star_parse=#{Dot_star_parse.inspect}, RegexpParse.promote(['.', '*'])=#{RegexpParse.promote(['.', '*']).inspect}")
    assert_equal(Dot_star_parse, RegexpParse.promote(/.*/))
  end # RegexpParse.promote

  def test_to_a
    CONSTANT_PARSE_TREE.assert_post_conditions
    assert_equal(['K'], CONSTANT_PARSE_TREE.parse_tree, "KC_parse=#{KC_parse.inspect}")
    assert_equal(['K'], CONSTANT_PARSE_TREE.to_a, "KC_parse=#{KC_parse.inspect}")
    Dot_star_parse.assert_invariant
    Dot_star_parse.assert_post_conditions
    message = "Dot_star_parse=#{Dot_star_parse.inspect}"
    message += " Dot_star_parse.parse_tree=#{Dot_star_parse.parse_tree.inspect}"
    message += " Dot_star_parse.parse_tree.join=#{Dot_star_parse.parse_tree.join.inspect}"
    assert_equal(Dot_star_parse.regexp_string, Dot_star_parse.parse_tree.join, message)
    assert_equal(Dot_star_parse.regexp_string, Dot_star_parse.parse_tree.to_a.join, '')
  end # to_a

  def test_RegexpParse_to_s
    assert_equal('.*', Dot_star_parse.to_s)
  end # to_s

  def test_to_regexp
    regexp = /abc/
    assert_equal(RegexpParse.new(regexp).to_regexp, regexp)
  end # to_regexp

  def test_to_pathname_glob
    assert_equal('ab', RegexpParse.new(/ab/).to_pathname_glob)
    assert_equal('[ab]', RegexpParse.new(/[ab]/).to_pathname_glob)
    assert_equal('ab', RegexpParse.new(/(ab)/).to_pathname_glob)
    #	open_tax_filler_directory="../OpenTaxFormFiller/(?<tax_year>[0-9]{4}}"
    open_tax_filler_directory = '../OpenTaxFormFiller/([0-9]{4})'
    #	assert_equal('ab', RegexpTree.new(open_tax_filler_directory).to_pathname_glob)
    file_regexp = "#{open_tax_filler_directory}/field_dump/Federal/f*.pjson"
    #	regexp=RegexpTree.new(file_regexp)
    #	assert_equal('*', regexp.to_pathname_glob)
  end # to_pathname_glob

  def test_pathnames
    open_tax_filler_directory = '../OpenTaxFormFiller/(?<tax_year>[0-9]{4}}'
    file_regexp = "#{open_tax_filler_directory}/field_dump/Federal/f*.pjson"
    regexp = RegexpParse.new(file_regexp)
    #	regexp.pathnames.compact.map{|matchData| matchData[1]}
  end # pathnames

  def test_grep
    delimiter = "\n"
  end # grep
  # RegexpParse.assert_pre_conditions
end # RegexpParseType

class RegexpTest < TestCase
	include Regexp::Expression::Base::Examples
  include RegexpParseType::Examples
  include Connectivity::Examples
	
  def test_raw_capture?
    #	assert_equal([], RegexpParseType.map_recursive(Literal_a, :expressions){|e, depth, terminal| [e.quantifier, e.to_s]}, Literal_a_map)
    assert_equal('*', Grandson_a.quantifier.text)
    assert_equal('*', Grandson_a.quantifier.to_s)
    e = Grandson_a
    assert_equal(-2, -1 - e.quantifier.to_s.size)
    assert_equal('a*', Grandson_a.to_s)
    assert_equal('a', Grandson_a.to_s[0..-2])
    assert_equal('a', Grandson_a.to_s[0..-1 - e.quantifier.to_s.size], Grandson_a.inspect)
    assert_instance_of(Array, Literal_a.raw_capture?('a'))
    assert_instance_of(Array, Regexp::Parser.parse(/a*b/.to_s, 'ruby/1.8').raw_capture?('aab'))
    a_star_parse = Regexp::Parser.parse(/a*/.to_s, 'ruby/1.8')
		message = RegexpParseType.inspect_recursive(a_star_parse)
		message += "\n" + a_star_parse.inspect
    a_star_capture = a_star_parse.raw_capture?('aa')
    assert_instance_of(Array, a_star_capture)
		a_star_capture.each do |element|
	    if (element.class == Array)
				assert_instance_of(Array, element, message)
	    elsif (element.class == Hash)
				assert_instance_of(Hash, element, message)
			else
				raise message
			end # if
		end # each
		a_star_capture.flatten.map do |capture|
#	    assert_equal([], capture[:parse], capture[:parse].inspect_recursive)
	    assert_instance_of(Hash, capture, message)
			assert_includes(capture.keys, :parse)
			assert_includes(capture.keys, :raw_capture)
	    assert_kind_of(RawCapture, capture[:raw_capture], message)
			puts capture[:parse].inspect + ' # ' + capture[:raw_capture].inspect + "\n\n"
			puts RegexpParseType.map_recursive(capture[:parse], &Tree_node_format)
		end # map

  end # raw_capture?

    def test_quantifiers
			assert_equal([], Sequence_example.quantifiers.flatten.compact)
			assert_equal([], Alternative_example.quantifiers.flatten.compact)
			assert_equal([true], Literal_a.quantifiers.flatten.compact)
    end # quantifiers
		
    def test_Regexp_capture_inspect
      string = 'aa'
			RegexpParseType.map_recursive(Literal_a.raw_capture?(string)) do |capture, _depth, _terminal|
				assert_kind_of(Node, capture)
				assert_kind_of(Regexp::Expression::Base, capture[:parse])
				assert_kind_of(RawCapture, capture[:raw_capture])
				capture[:parse].inspect + ' # ' + 
					capture[:raw_capture].inspect + "\n\n" + 
					RegexpParseType.map_recursive(capture[:parse], &Tree_node_format)
			end # map_recursive
			assert_equal([], Literal_a.inspect_capture('aa'))
			assert_equal([], Sequence_example.inspect_capture('ab'))
			assert_equal([], Alternative_example.inspect_capture('b'))
    end # inspect
		
    def test_Regexp_Examples
	    assert_instance_of(Regexp::Expression::Root, Literal_a)
			assert_equal(1, Children_a.size)
	    assert_instance_of(Regexp::Expression::Group::Options, Son_a)
			assert_equal(1, Grandchildren_a.size)
	    assert_instance_of(Regexp::Expression::Literal, Grandson_a)
			assert_kind_of(Regexp::Expression::Base, Literal_a, Grandson_a.class.ancestors)
			assert_kind_of(Regexp::Expression::Base, Son_a, Grandson_a.class.ancestors)
			assert_kind_of(Regexp::Expression::Base, Grandson_a, Grandson_a.class.ancestors)
	    assert_equal(Grandson_a_map, RegexpParseType.map_recursive(Grandson_a, &Tree_node_format))
	    assert_equal(Son_a_map, RegexpParseType.map_recursive(Son_a, &Tree_node_format))
	    assert_equal(Literal_a_map, RegexpParseType.map_recursive(Literal_a, &Tree_node_format))
    end # Examples

		def vertex_iterator(parser)
			node_tree = RegexpParseType.map_recursive(parser) do |e, _depth, _terminal|
				e
			end # map_recursive
			node_tree.flatten
		end # vertex_iterator
		
		def adjacent_iterator(x, b)
          assert_kind_of(Regexp::Expression::Base, x)
          assert_instance_of(Proc, b)
					if x.respond_to?(:expressions)
						x.expressions.each do |y|
							assert_kind_of(Regexp::Expression::Base, y)
							unless x == y || y == Kernel || y == Object
								bcy = b.call(y)
								assert_instance_of(Array, bcy)
								assert_kind_of(Regexp::Expression::Base, bcy[0])
								bcy 
							end # unless
						end
					else
					end # if
		end # adjacent_iterator
		
    def module_graph(parser)
      RGL::ImplicitGraph.new do |g|
        g.vertex_iterator do |b|
          vertex_iterator(parser)
        end
        g.adjacent_iterator do |x, b|
          adjacent_iterator(x, b)
        end
        g.directed = true
      end
    end

	def test_module_graph
    g = module_graph(Literal_a)
		assert_equal([:@directed, :@vertex_iterator, :@adjacent_iterator], g.instance_variables)
		assert_instance_of(RGL::ImplicitGraph, g)
		message = MethodModel.prototype_list(RGL::ImplicitGraph, ancestor_qualifier: true, argument_delimeter: '(').join("\n")
		message += "\n" + MethodModel.ancestor_method_names(RGL::ImplicitGraph, instance: true, method_name_selection: /.+/, ancestor_selection: :ancestors).ruby_lines_storage
		message += "\n" + MethodModel.ancestor_method_names(RGL::ImplicitGraph, instance: true, method_name_selection: /.+/, ancestor_selection: :ancestors).inspect
		assert_equal([], g.methods(false), message)
		assert_equal([], g.methods(true), message)
    assert_match(/theMethod/, MethodModel.prototype_list(RGL::ImplicitGraph, ancestor_qualifier: true, argument_delimeter: '(').join("\n"), message)
    assert_match(/theMethod/, MethodModel.prototype_list(g, ancestor_qualifier: false, argument_delimeter: ' ').join("\n"), message)
    require 'rgl/traversal'
    tree = g.bfs_search_tree_from(Literal_a)
    # Now we want to visualize this component of g with DOT. We therefore create a subgraph of the original graph, using a filtered graph:

    g = g.vertices_filtered_by { |v| tree.has_vertex? v }
    g.write_to_graphic_file('jpg')
	end # module_graph
	
end # Regexp

require 'rgl/implicit'
require 'rgl/adjacency'
require 'rgl/dot'

class BoostGraphTest < TestCase
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

	def test_module_graph
    g = module_graph
    # We only want to see the ancestors of {RGL::AdjacencyGraph}:

    require 'rgl/traversal'
    tree = g.bfs_search_tree_from(RGL::AdjacencyGraph)
    # Now we want to visualize this component of g with DOT. We therefore create a subgraph of the original graph, using a filtered graph:

    g = g.vertices_filtered_by { |v| tree.has_vertex? v }
#    g.write_to_graphic_file('jpg')
	end # module_graph
end # BoostGraph