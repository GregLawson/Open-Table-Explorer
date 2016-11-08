###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../app/models/test_environment_minitest.rb'
require_relative '../../test/assertions/branch_assertions.rb'
require_relative '../../test/assertions/shell_command_assertions.rb'
require_relative '../../app/models/method_model.rb'
# require_relative '../../test/assertions/repository_assertions.rb'
# require_relative '../../app/models/branch.rb'
class BranchTest < TestCase
  # include DefaultTests
  # include Repository::Examples
  include Branch::Constants
  include BranchReference::Examples
  include Branch::Examples
  def setup
    @temp_repo = Repository.create_test_repository
  end # setup

  def teardown
    Repository.delete_existing(@temp_repo.path)
  end # teardown
  include BranchReference::DefinitionalConstants

  def test_Branch_Constants
  end # Constants

  def test_branch_symbol?
    assert_equal(:master, Branch.branch_symbol?(-1))
    assert_equal(:passed, Branch.branch_symbol?(0))
    assert_equal(:tested, Branch.branch_symbol?(1))
    assert_equal(:edited, Branch.branch_symbol?(2))
    assert_equal(:stash, Branch.branch_symbol?(3))
    assert_equal(:'stash~1', Branch.branch_symbol?(4))
    assert_equal(:'stash~2', Branch.branch_symbol?(5))
    assert_equal(:work_flow, Branch.branch_symbol?(-3))
    assert_equal(:tax_form, Branch.branch_symbol?(-2))
    assert_equal(:'origin/master', Branch.branch_symbol?(-4))
  end # branch_symbol?

  def test_branch_index?
    assert_equal(0, Branch.branch_index?(:passed))
    assert_equal(1, Branch.branch_index?(:tested))
    assert_equal(2, Branch.branch_index?(:edited))
    assert_equal(3, Branch.branch_index?(:stash))
    assert_equal(4, Branch.branch_index?(:'stash~1'))
    assert_equal(5, Branch.branch_index?(:'stash~2'))
    assert_equal(-1, Branch.branch_index?(:master))
    assert_equal(-2, Branch.branch_index?(:tax_form))
    assert_equal(-3, Branch.branch_index?(:work_flow))
    assert_equal(-4, Branch.branch_index?(:'origin/master'))
    assert_equal(nil, Branch.branch_index?('/home/greg'))
  end # branch_index?

  def test_merge_range
    assert_equal(1..2, Branch.merge_range(:passed))
    assert_equal(2..2, Branch.merge_range(:tested))
    assert_equal(3..2, Branch.merge_range(:edited))
    assert_equal(0..2, Branch.merge_range(:master))
  end # merge_range

  def test_branch_capture
    repository = @temp_repo
    git_command = 'branch --list'
    branch_output = repository.git_command(git_command).output # .assert_post_conditions
    parse = branch_output.parse(Branch_regexp)
  end # branch_capture?

  def test_current_branch_name?
    #	assert_includes(UnitMaturity::Branch_enhancement, WorkFlow.current_branch_name?, Repo.head.inspect)
    branch_output = @temp_repo.git_command('branch --list') # .assert_post_conditions.output
    #	assert_equal([:master, :passed], Branch.current_branch_name?(@temp_repo))
  end # current_branch_name

  def test_branches?
    # ?	explain_assert_respond_to(Parse, :parse_split)
    branch_output = @temp_repo.git_command('branch --list').output # .assert_post_conditions
    Patterns.each do |p|
      assert_match(p, branch_output)
      branches = branch_output.capture?(p, LimitCapture)
#      puts branches.inspect if branches.success?
      # ?		assert_equal([{:branch=>"master"}, {:branch=>"passed"}], branches.output, branches.inspect)
    end # each

    assert_includes(Branch.branches?(@temp_repo).map(&:name), @temp_repo.current_branch_name?)
    #	assert_includes(Branch.branches?(Repository::This_code_repository).map{|b| b.name}, Repository::This_code_repository.current_branch_name?)
    # ?	assert_equal([:master, :passed], Branch.branches?(@temp_repo).map{|b| b.name})
    # ?	assert_includes(Branch.branch_names?(This_code_repository), This_code_repository.current_branch_name?)
  end # branches?

  def test_remotes?
    pattern = /  / * /[a-z0-9\/A-Z]+/.capture(:remote)
    remote_run = This_code_repository.git_command('branch --list --remote')
    captures = remote_run.output.capture?(pattern, SplitCapture)
    This_code_repository.git_parse('branch --list --remote', pattern)
    assert_empty(Branch.remotes?(@temp_repo))
    refute_empty(Branch.remotes?(This_code_repository))
  end # remotes?

  def test_merged?
    assert_equal({ merged: 'passed' }, Branch.merged?(@temp_repo))
    refute_empty(Branch.merged?(This_code_repository))
  end # merged?

  def test_branch_names?
    #	assert(Branch.branch_names?.include?(:master), Branch.branch_names?.inspect)
  end # branch_names?

  def test_revison_tag?
    assert_equal('-r master', Branch.revison_tag?(-1))
    assert_equal('-r passed', Branch.revison_tag?(0))
    assert_equal('-r tested', Branch.revison_tag?(1))
    assert_equal('-r edited', Branch.revison_tag?(2))
    assert_equal('-r stash', Branch.revison_tag?(3))
    assert_equal('-r stash~1', Branch.revison_tag?(4))
    assert_equal('-r stash~2', Branch.revison_tag?(5))
    assert_equal('-r work_flow', Branch.revison_tag?(-3))
    assert_equal('-r origin/master', Branch.revison_tag?(-4))
  end # revison_tag?
	
	def test_stash_wip
		wip_example = "stash@{0}: WIP on testing: 0eeec72 Merge branch 'passed' into testing"
		command_string = 'show stash'
		cached_run = Repository::This_code_repository.git_command(command_string)
#		assert_include([Master_branch, Passed_branch, Tested_branch, Edited_branch], Branch.stash_wip(Repository::This_code_repository))
	end # stash_wip

  def test_initialize
    assert_equal(This_code_repository, Branch.new(repository: This_code_repository).repository)

    branch = This_code_repository.current_branch_name?
    onto = Branch::Examples::Executing_branch.find_origin
  end # values

  def test_to_s
  end # to_s

  def test_to_sym
  end # to_s

  def test_compare
		assert_operator(Executing_branch, :==, Executing_branch)
		assert_operator(Passed_branch, :==, Passed_branch)
		assert_operator(Edited_branch, :==, Edited_branch)
		assert_operator(Tested_branch, :==, Tested_branch)
		assert_instance_of(Branch, Tested_branch)
		assert_includes(Branch.instance_methods(false), :<=>)
#		assert_includes(Tested_branch.methods(false), :<=>)
		assert_operator(Branch.branch_index?(:passed), :<, Branch.branch_index?(:tested))
		assert_equal(-1, Branch.branch_index?(:passed) <=> Branch.branch_index?(:tested))
		assert_equal(+1, -(Branch.branch_index?(:passed) <=> Branch.branch_index?(:tested)))
		assert_operator(Passed_branch, :>, Tested_branch)
		assert_operator(Tested_branch, :>, Edited_branch)
		assert_operator(Passed_branch, :>, Edited_branch)
    branches = Branch.branches?(Repository::This_code_repository)
    assert_instance_of(Array, branches)
    branch0 = branches[0]
    comparisons_fail = branches.select do |branch|
      assert_instance_of(Branch, branch)
      (branch <=> branch0).nil?
    end # each
    assert_includes(comparisons_fail.map(&:name), :edited_interactive)
    #    sorted_branches = branches.sort.map(&:name)
    #	assert_equal([], sorted_branches)

    #    assert_operator(sorted_branches[0], :==, sorted_branches[0])
  end # compare

	def test_find_origin
		assert_equal(nil, Master_branch.find_origin)
#		assert_equal(false, Passed_branch.find_origin)
#		assert_equal(false, Tested_branch.find_origin)
#		assert_equal(false, Edited_branch.find_origin)
  end # find_origin
	
	def test_interactive?
		assert_equal(nil, Master_branch.interactive?)
		assert_equal(nil, Passed_branch.interactive?)
		assert_equal(nil, Tested_branch.interactive?)
		assert_equal(nil, Edited_branch.interactive?)
	end # interactive?
	
	def test_maturity
	end # maturity
	
	def test_succ
    assert_equal(2, Branch.branch_index?(:edited))
		assert_equal(3, Edited_branch.succ)
		assert_equal(nil, Stash_branch.succ)
		assert_equal(Branch.branch_index?(:passed), Master_branch.succ)
		assert_equal(Branch.branch_index?(:edited), Tested_branch.succ)
		assert_equal(nil, Stash_branch.succ)
		assert_equal(Branch.branch_index?(:tested), Passed_branch.succ)
	end # succ
	
	def test_less_mature
		assert_equal([], Stash_branch.less_mature)
#		assert_equal([Stash_branch], Edited_branch.less_mature)
#		assert_equal([Passed_branch], Master_branch.less_mature)
#		assert_equal([Edited_branch], Passed_branch.less_mature)
	end # less_mature
	
		def vertex_iterator
			All_standard_branches
		end # vertex_iterator
		
		def adjacent_iterator(branch, block) # point to less mature (merge down) branch
			regexp = /[_a-z]+/.capture(:maturity) * /_interactive/.capture(:interactive).optional
			capture = branch.to_s.capture?(regexp)
			assert_kind_of(Branch, branch)
			assert_instance_of(Proc, block)
			ret = branch.less_mature
			if branch.respond_to?(:expressions)
				branch.expressions.each do |y|
					assert_kind_of(Branch, y)
					unless branch == y || y == Kernel || y == Object
						bcy = block.call(y)
						assert_instance_of(Array, bcy)
						assert_kind_of(Branch, bcy[0])
						bcy 
					end # unless
				end
			else
			end # if
		end # adjacent_iterator
		
    def module_graph(parser)
      RGL::ImplicitGraph.new do |g|
        g.vertex_iterator do |b|
          vertex_iterator
        end
        g.adjacent_iterator do |x, b|
          adjacent_iterator(x, b)
        end
        g.directed = true
      end
    end

	def test_module_graph
    g = module_graph(Passed_branch)
		assert_equal([:@directed, :@vertex_iterator, :@adjacent_iterator], g.instance_variables)
		assert_instance_of(RGL::ImplicitGraph, g)
		message = MethodModel.prototype_list(RGL::ImplicitGraph, ancestor_qualifier: true, argument_delimeter: '(').join("\n")
		message += "\n" + MethodModel.ancestor_method_names(RGL::ImplicitGraph, instance: true, method_name_selection: /.+/, ancestor_selection: :ancestors).ruby_lines_storage
		message += "\n" + MethodModel.ancestor_method_names(RGL::ImplicitGraph, instance: true, method_name_selection: /.+/, ancestor_selection: :ancestors).inspect
		assert_equal([], g.methods(false), message)
#		assert_equal([:vertex_iterator, :adjacent_iterator, :directed=, :directed?, :each_vertex, :each_adjacent, :each_edge, :edge_iterator], g.methods(true), message)
    assert_match(/vertex_iterator/, MethodModel.prototype_list(RGL::ImplicitGraph, ancestor_qualifier: true, argument_delimeter: '(').join("\n"), message)
#    assert_match(/vertex_iterator/, MethodModel.prototype_list(g, ancestor_qualifier: false, argument_delimeter: ' ').join("\n"), message)
    require 'rgl/traversal'
    tree = g.bfs_search_tree_from(Passed_branch)
    # Now we want to visualize this component of g with DOT. We therefore create a subgraph of the original graph, using a filtered graph:

    g = g.vertices_filtered_by { |v| tree.has_vertex? v }
    g.write_to_graphic_file('jpg')
	end # module_graph
	
end # Branch

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