###########################################################################
#    Copyright (C) 2012-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/require.rb'
class RequireTest < TestCase
  # include DefaultTests
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
    include Require::Examples
  end # Examples
	include Examples
  include RailsishRubyUnit::Executable.model_class?::Examples
  def test_DefinitionalConstants
    assert_match(/require/ * /_relative/.capture(:require_command) * /\s+/, Require_line)
    assert_match(/require/ * /_relative/.capture(:require_command) * /\s+/ * /['"]/, Require_line)
    assert_match(FilePattern::Relative_pathname_included_regexp.capture(:required_path), Require_line)
    assert_match(/require/ * /_relative/.capture(:require_command) * /\s+/ * /['"]/ * FilePattern::Relative_pathname_included_regexp.capture(:required_path), Require_line)
    assert_match(Require_regexp, Require_line)
		
    assert_match(/^require/ * /_relative/.capture(:require_command).group * Regexp::Optional * /\s+/, Nonrelative_line)
    assert_match(Relative_regexp, Nonrelative_line)
    assert_match(FilePattern::Relative_pathname_included_regexp.capture(:required_path), Nonrelative_line)
    assert_match(Relative_regexp, Nonrelative_line)
    assert_match(Relative_regexp, Nonrelative_line)

    assert_match(/\s*/ * /#/, Nonrelative_line)
    assert_match(/\s*/ * /#/ * /[^\n]*/, Nonrelative_line)
    assert_match(/\s*/ * /#/ * /[^\n]*/.capture(:comment) * /\n/, Nonrelative_line)
    assert_match(End_of_line_comment, Nonrelative_line)
    assert_match(Require_regexp, Nonrelative_line)
		
    capture = Nonrelative_line.capture?(Require_regexp, MatchCapture)
		assert_instance_of(MatchCapture, capture)
    assert_equal({ require_command: 'require', required_path: 'active_support' }, capture.output)
    assert_equal(capture.num_captures, capture.to_a.size, capture.inspect)
		assert_nil(capture.output[:relative])

    capture = Nonrelative_line.capture?(Require_regexp, SplitCapture)
		assert_instance_of(SplitCapture, capture)

    capture = Nonrelative_line.capture?(Require_regexp * End_of_line_comment, SplitCapture)
		assert(capture.success?, capture.inspect)
#    assert_equal(capture.num_captures + 2, capture.raw_captures.size, capture.inspect)
    assert_equal(capture.num_captures, capture.to_a(0).size, capture.inspect)
		expected_answer = { require_command: 'require', required_path: 'active_support', :comment=>" for singularize and pluralize" }
		assert_equal([expected_answer],capture.output, capture.inspect)
		assert_equal('require', capture.output[0][:require_command], capture.inspect)
    assert_equal({ require_command: 'require', required_path: 'active_support', :comment=>" for singularize and pluralize" }, capture.output[0])
  end # DefinitionalConstants
		def test_capture_to_hash
			capture = Nonrelative_line.capture?(Require_regexp, SplitCapture)
			assert_equal({}, Require.capture_to_hash(capture))
			capture = Nonrelative_line.capture?(Require_regexp, MatchCapture)
			assert_equal({}, Require.capture_to_hash(capture))
		end # capture_to_hash

  def test_parse_output
    assert_match(Require_regexp, Require_line)
    #    assert_match(Relative_regexp * /\s+/, Require_line)
    parse = Require_line.capture?(Require_regexp, MatchCapture).output
    assert_equal({ require_command: 'require_relative', required_path: '../../app/models/unit.rb' }, parse)
    parse_array = Require_line.capture?(Require_regexp, SplitCapture).output
		assert_instance_of(Array, parse_array)
    assert_equal([{ require_command: 'require_relative', required_path: '../../app/models/unit.rb' }], parse_array)

    path = 'test/unit/test_run_test.rb'
    capture =  Require.parse_output(path, SplitCapture)
    assert_equal({:require_command=>"require", :required_path=>"active_support"}, capture.output[1])
#    assert_equal([{ require_command: 'require_relative', required_path: '../../app/models/unit.rb' }], capture.output)
    end # parse_output

  def test_scan_path
    path = 'test/unit/test_run_test.rb'
      capture = Require.parse_output(path, SplitCapture)
		assert_instance_of(SplitCapture, capture)
			ret =
				capture.output.enumerate(:map) do |output| 
					assert_kind_of(Hash, output)
					if output[:require_command] == 'require' # don't recurse
						output[:required_path]
					else
						assert_instance_of(Hash, output)
						relative_path = File.dirname(path) + '/' + output[:required_path]
						Require.scan_path(relative_path)
					end # if
				end # if
    requires = Require.scan_path(path)
		assert_instance_of(Hash, requires)
    assert_equal({ model: { require_command: 'require_relative', required_path: '../../app/models/no_db.rb' },
                   unit: { require_command: 'require_relative', required_path: 'test_environment' } },
                 requires.output)
  end # scan_path

  def test_scan_unit
		ret = {}
    Unit::Executable.edit_files.each do |file|
        parse = Require.parse_output(file, SplitCapture)
      parse.output.enumerate(:each) do |output|
        assert_instance_of(Hash, output)
        assert_includes(output.keys, :required_path)
          assert_includes(['require', 'require_relative'], output[:require_command], output)
      end # each
      keys = parse.output.enumerate(:map, &:keys).flatten.uniq
      assert_equal([:require_command, :required_path], keys)
      ret = ret.merge(FilePattern.find_from_path(file)[:name] => parse)
    end # each
    assert_instance_of(Hash, ret)
    assert_equal(ret, Require.scan_unit(Unit::Executable))
  end # scan_unit
  def test_Require_attributes
    executing_requires = Require.new(path: $0)
    assert_instance_of(Hash, executing_requires.cached_require_captures)
    assert_includes(executing_requires.cached_require_captures.keys, :require_command)
    assert_instance_of(Array, executing_requires.cached_require_captures)
    executing_requires.assert_relative(Require_line, Relative_regexp)
  end # values
	
	def test_require_graph

    g = module_graph
    # We only want to see the ancestors of {RGL::AdjacencyGraph}:

    require 'rgl/traversal'
    tree = g.bfs_search_tree_from(RGL::AdjacencyGraph)
    # Now we want to visualize this component of g with DOT. We therefore create a subgraph of the original graph, using a filtered graph:

    g = g.vertices_filtered_by { |v| tree.has_vertex? v }
    g.write_to_graphic_file('jpg')
	end # require_graph
end # Require

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
    g.write_to_graphic_file('jpg')
	end # module_graph
end # BoostGraph