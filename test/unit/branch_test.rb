###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative '../unit/test_environment'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../test/assertions/branch_assertions.rb'
require_relative '../../test/assertions/shell_command_assertions.rb'
require_relative '../../app/models/method_model.rb'
# require_relative '../../test/assertions/repository_assertions.rb'
# require_relative '../../app/models/branch.rb'
class BranchTest < TestCase
  # include DefaultTests
  include Repository::Examples
  include Branch::Constants
  include Branch::ReferenceObjects
  #  include Branch::Examples
  module Examples
    #    include Constants
    # Empty_repo_master_branch=Branch.new( Repository::Examples::Empty_Repo, :master)
    Executing_branch = Branch.new(repository: Repository::Examples::This_code_repository, name: Commit.head(Repository::Examples::This_code_repository))
    # Executing_master_branch=Branch.new(Repository::Examples::This_code_repository, :master)
  end # Examples
  include Examples

  def setup
    @temp_repo = Repository.create_test_repository
  end # setup

  def teardown
    Repository.delete_existing(@temp_repo.path)
  end # teardown

  def reset_temp
    Repository.delete_existing(@temp_repo.path)
    @temp_repo = Repository.create_test_repository
  end # reset_temp

  include BranchReference::DefinitionalConstants

  def test_MaturityBranches
    # explore possible branch name characters
    # see man git checkout for why dot should not be used in branch names
    branch_characters = Regexp.character_array do |character|
      git_run = @temp_repo.git_command('branch ' + character)
      git_run.success?
    end # character_array
    puts branch_characters.join.inspect
    reset_temp
    literal_characters = CharacterEscape.select_characters(:literal) - [':', '<', '>', '`', '~', '%']
    literal_characters.each do |character|
      @temp_repo.git_command('branch ' + character).assert_post_conditions('character = ' + character.inspect)
    end # each

    assert_match(Name_regexp, 'passed+interactive')
  end # MaturityBranches

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
    assert_equal([{ current: '*', branch: 'master' }, { current: ' ', branch: 'passed' }], Branch.branch_capture?(@temp_repo).output)
  end # branch_capture?

  def test_current_branch_name?
    #	assert_includes(UnitMaturity::Branch_enhancement, WorkFlow.current_branch_name?, Repo.head.inspect)
    branch_capture = Branch.branch_capture?(@temp_repo)
    branch_capture.assert_post_conditions
    branch_output = branch_capture.output
    assert_includes(branch_output, { current: '*', branch: 'master' }, branch_capture.inspect)
    current_branch_name = Branch.current_branch_name?(This_code_repository)
    assert_instance_of(Symbol, current_branch_name)
    # exists @temp_repo.git_command("branch details").assert_post_conditions
    # exists @temp_repo.git_command("branch summary").assert_post_conditions
    #	assert_includes(WorkFlow::Branch_enhancement, Repo.head.name.to_sym, Repo.head.inspect)
    #	assert_includes(WorkFlow::Branch_enhancement, WorkFlow.current_branch_name?, Repo.head.inspect)
  end # current_branch_name

  def test_current_branch
    current_branch = Branch.current_branch(This_code_repository)
    assert_instance_of(Branch, current_branch)
    temp_current_branch = Branch.current_branch(@temp_repo)
    assert_instance_of(Branch, temp_current_branch)
    assert_equal(temp_current_branch.sha1_hex_40, Commit.head(@temp_repo).sha1_hex_40)
    assert_equal(Branch.current_branch(This_code_repository).sha1_hex_40, Commit.head(This_code_repository).sha1_hex_40)
  end # current_branch

  def test_branches?
    # ?	explain_assert_respond_to(Parse, :parse_split)
    branch_output = @temp_repo.git_command('branch --list').output # .assert_post_conditions
    Patterns.each do |p|
      assert_match(p, branch_output)
      branches = branch_output.capture?(p, LimitCapture)
      #      puts branches.inspect if branches.success?
      # ?		assert_equal([{:branch=>"master"}, {:branch=>"passed"}], branches.output, branches.inspect)
    end # each

    assert_includes(Branch.branches?(@temp_repo).map(&:name), Branch.current_branch_name?(@temp_repo))
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

  def test_initialize
    assert_equal(This_code_repository, Branch.new(repository: This_code_repository).repository)

    branch = Branch.current_branch_name?(This_code_repository)
    onto = Executing_branch.find_origin
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
    #    assert_includes(comparisons_fail.map(&:name), :"edited+interactive")
    #    sorted_branches = branches.sort.map(&:name)
    #	assert_equal([], sorted_branches)

    #    assert_operator(sorted_branches[0], :==, sorted_branches[0])
  end # compare

  def test_find_origin
    assert_equal(:'origin/master', Master_branch.find_origin)
    assert_equal(:'origin/passed', Passed_branch.find_origin)
    #		assert_equal(:'origin/tested', Tested_branch.find_origin)
    assert_equal(:'origin/edited', Edited_branch.find_origin)
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
    capture = branch.to_s.capture?(Name_regexp)
    assert_kind_of(Branch, branch)
    assert_instance_of(Proc, block)
    ret = branch.less_mature
    if branch.respond_to?(:expressions)
      branch.expressions.each do |y|
        assert_kind_of(Branch, y)
        next if branch == y || y == Kernel || y == Object
        bcy = block.call(y)
        assert_instance_of(Array, bcy)
        assert_kind_of(Branch, bcy[0])
        bcy
        # unless
      end
    end # if
  end # adjacent_iterator

  def module_graph(_parser)
    RGL::ImplicitGraph.new do |g|
      g.vertex_iterator do |_b|
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

class BranchReferenceTest < TestCase
  module Examples
    include BranchReference::DefinitionalConstants
    include Branch::ReferenceObjects
    Reflog_line = 'master@{123},refs/heads/master@{123},1234567,Sun, 21 Jun 2015 13:51:50 -0700'.freeze
    Reflog_capture = Reflog_line.capture?(BranchReference::Reflog_line_regexp)
    Reflog_run_executable = Repository::This_code_repository.git_command('reflog  --all --pretty=format:%gd,%gD,%h,%aD -- ' + $PROGRAM_NAME)
    Reflog_lines = Reflog_run_executable.output.split("\n")
    #    Reflog_reference = BranchReference.new_from_ref(Reflog_line)
    Last_change_line = Reflog_lines[0]
    First_change_line = Reflog_lines[-1]
    No_ref_line = ',,911dea1,Sun, 21 Jun 2015 13:51:50 -0700'.freeze
    Stash_line = 'stash@{123},refs/stash@{123},1234567,Sun, 21 Jun 2015 13:51:50 -0700'.freeze
  end # Examples
  include Examples

  include Repository::Examples
  include BranchReference::DefinitionalConstants

  def setup
    @temp_repo = Repository.create_test_repository
  end # setup

  def teardown
    Repository.delete_existing(@temp_repo.path)
  end # teardown

  def test_reflog_command_string
    filename = 'log/unit/1.9/1.9.3p194/silence/repository.log'
    repository = This_code_repository
    range = 0..10
    reflog_run = repository.git_command(BranchReference.reflog_command_string(filename, repository, range))
    assert(reflog_run.success?, reflog_run.inspect)
  end # reflog_command_string

  def test_reflog_command_output
    filename = 'log/unit/1.9/1.9.3p194/silence/repository.log'
    repository = This_code_repository
    range = 0..10
    reflog_command_lines = BranchReference.reflog_command_lines(filename, repository, range)
    assert_operator(4, :<, reflog_command_lines.size, reflog_command_lines.inspect)
  end # reflog_command_lines

  def test_reflog?
    filename = 'log/unit/1.9/1.9.3p194/silence/repository.log'
    #	filename = $0
    repository = This_code_repository
    range = 0..10
    #	reflog?(filename).output.split("/n")[0].split(',')[0]
    reflog_run = repository.git_command(BranchReference.reflog_command_string(filename, repository, range))
    #	Reflog_run_executable.assert_post_conditions
    lines = reflog_run.output.split("\n")
    manual_reflog = lines.map do |reflog_line|
      refute_equal('', reflog_line, Reflog_lines.inspect)
      #		BranchReference.assert_reflog_line(reflog_line)
      #      BranchReference.new_from_ref(reflog_line)
      #		new(capture.output[:ambiguous_branch].to_sym,capture.output[:age].to_i)
    end # map
    #    reflog = BranchReference.reflog?(filename, This_code_repository)
    #	assert_equal(manual_reflog, reflog, reflog.inspect)
    #    refute_equal([], reflog, BranchReference.reflog_command_string(filename, repository, range = 0..10).inspect)
    #	reflog.assert_post_conditions
    #	refute_empty(reflog.output)
    ##	lines = reflog.output.split("\n")
    #	assert_instance_of(Array, reflog)
    #	assert_operator(reflog.size, :>,1, reflog)
    #	assert_equal('', reflog[0], lines)
    #		unique_ambiguous_branches = reflog.map {|br| br[:ambiguous_branch] }.uniq
    #		unique_unambiguous_branches = reflog.map {|br| br[:unambiguous_branch] }.uniq
    #		assert_equal([], unique_ambiguous_branches)
    #		assert_equal([], unique_unambiguous_branches)

    filename = $PROGRAM_NAME
    repository = Repository::This_code_repository
    range = 0..2
    lost_code = 'def testing_superset_of_passed'
    reflogs_0_2 = BranchReference.reflog?(filename, repository, range, options = '-S "' + lost_code.to_s + '"')
    assert_instance_of(Array, reflogs_0_2)
    assert_kind_of(GitReference, reflogs_0_2[0], reflogs_0_2.inspect)
    assert_equal(3, reflogs_0_2.size)

    range = 1..2
    reflogs_1_2 = BranchReference.reflog?(filename, repository, range, options = '-S "' + lost_code.to_s + '"')
    assert_equal(2, reflogs_1_2.size)
    assert_equal(reflogs_1_2, reflogs_0_2[1..-1])

    range = 0..10
    lost_code = 'def testing_superset_of_passed'
    reflogs = BranchReference.reflog?(filename, repository, range, options = '-S "' + lost_code.to_s + '"')
    assert_instance_of(Array, reflogs)
    reflogs.each do |commit|
      assert_kind_of(GitReference, commit)
      file = GitReference.new(initialization_string: commit.sha1_hex_40 + ':' + filename).show_run.output
      if file.match(lost_code)
        puts 'matched in ' + commit.inspect
      else
        puts 'unmatched in ' + commit.inspect
      end # if
    end # each
  end # reflog?

  def test_last_change?
    filename = $PROGRAM_NAME
    repository = @temp_repo
    reflog = BranchReference.reflog?(filename, repository)
    assert_equal(nil, BranchReference.last_change?(filename, repository))
    #	assert_includes(Branch.branch_names?(This_code_repository), BranchReference.last_change?(filename, This_code_repository).initialization_string)
  end # last_change?

  def test_lost_edit
    filename = $PROGRAM_NAME
    repository = Repository::This_code_repository
    range = 0..10
    lost_code = 'def testing_superset_of_passed'
    reflogs = BranchReference.reflog?(filename, repository, range, options = '-S "' + lost_code.to_s + '"')
    assert_instance_of(Array, reflogs)
    reflogs.each do |commit|
      assert_kind_of(GitReference, commit)
      file = GitReference.new(initialization_string: commit.sha1_hex_40 + ':' + filename).show_run.output
      if file.match(lost_code)
        puts 'matched in ' + commit.inspect
      else
        puts 'unmatched in ' + commit.inspect
      end # if
    end # each
  end # lost_edit

  def test_reflog_to_constructor_hash
    Reflog_lines.each do |reflog_line|
      capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
      #      reflog_to_constructor_hash = BranchReference.reflog_to_constructor_hash(reflog_line)
      #      BranchReference.assert_reflog_line(reflog_line)
    end # each
  end # reflog_to_constructor_hash

  def test_BranchReference_DefinitionalConstants
    assert_match(BranchReference::Ambiguous_ref_pattern, Reflog_line)
    assert_match(/@\{/ * Unambiguous_ref_age_pattern * /}/, Reflog_line)
    assert_match(/refs\/heads\//, Reflog_line)
    assert_match(Ambiguous_ref_pattern.capture(:unambiguous_branch), Reflog_line)
    assert_match(Unambiguous_ref_age_pattern * /}/, Reflog_line)
    #    matches = ParsedCapture.show_matches([Reflog_line], Regexp_array)
    matches = ParsedCapture.show_matches([Reflog_line], [Unambiguous_ref_pattern])
    #		matches = ParsedCapture.priority_match([Reflog_line], Regexp_array)
    #    puts matches.inspect
    assert_equal('123', Reflog_line.capture?(Ambiguous_ref_pattern).output[:age], matches.ruby_lines_storage)
    assert_equal('master', Reflog_line.capture?(Ambiguous_ref_pattern).output[:maturity], matches.ruby_lines_storage)
    assert_equal(nil, Reflog_line.capture?(Ambiguous_ref_pattern).output[:test_topic], matches.ruby_lines_storage)
    assert_equal({ age: '123', maturity: 'master', test_topic: nil, scope: nil }, Reflog_line.capture?(Ambiguous_ref_pattern).output, matches.ruby_lines_storage)
    unambiguous_branch = Reflog_line.capture?(Refs_prefix_regexp * Ambiguous_ref_pattern)
    assert(unambiguous_branch.success?, unambiguous_branch.inspect)
    #    assert_equal(['123'], unambiguous_branch.raw_captures[0..-1], unambiguous_branch.regexp.named_captures.inspect)
    assert_equal('123', unambiguous_branch.output[:age], unambiguous_branch.inspect)
    assert_equal('master', unambiguous_branch.output[:maturity], unambiguous_branch.inspect)
    assert_equal(nil, unambiguous_branch.output[:test_topic], unambiguous_branch.inspect)
    assert_equal('heads', unambiguous_branch.output[:ref], unambiguous_branch.inspect)
    assert_equal({ age: '123', ref: 'heads', maturity: 'master', test_topic: nil, scope: nil }, unambiguous_branch.output, matches.ruby_lines_storage)
    timestamp = MatchCapture.new(string: Reflog_line, regexp: Git_reflog_timestamp_regexp_array)
    assert_equal({ day_of_month: '21', hour: '13', minute: '51', month: 'Jun', second: '50', timezone: '-0700',
                   weekday: 'Sun', year: '2015' }, timestamp.output, timestamp.ruby_lines_storage)
    assert_match(BranchReference::Unambiguous_ref_pattern, Reflog_line)
    BranchReference.assert_reflog_line(Reflog_line)
    BranchReference.assert_reflog_line(Last_change_line)
    BranchReference.assert_reflog_line(First_change_line)
    BranchReference.assert_reflog_line(Stash_line)
    BranchReference.assert_reflog_line(No_ref_line)
    Reflog_lines.each do |reflog_line|
      Regexp_array.each do |regexp|
        assert_match(regexp, reflog_line)
      end # each
      assert_match(BranchReference::Reflog_line_regexp, reflog_line)
      BranchReference.assert_reflog_line(reflog_line)
      #        refute_equal([], priority_match, show_matches.ruby_lines_storage)
      #        assert_match(BranchReference::Ambiguous_ref_pattern, reflog_line)
      #        assert_match(BranchReference::Unambiguous_ref_pattern, reflog_line)
    end # each
  end # DefinitionalConstants

  def test_new_from_ref
    reflog_line = No_ref_line
    #	Test capture with reflog line having no refs
    message = 'reflog_line = ' + reflog_line.inspect
    capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
    message += "\ncapture = " + capture.inspect
    refs = reflog_line.split(',')
    message += "\nrefs = " + refs.inspect
    assert_equal(refs[0], '', message)

    #	Test method
    br = BranchReference.new_from_ref(reflog_line)
    #    assert_equal(refs[2].to_sym, br.name, br.inspect)

    # Now test one with refs
    reflog_line = Last_change_line
    capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
    #	Test method

    br = BranchReference.new_from_ref(reflog_line)
    refs = reflog_line.split(',')
    refute_equal(refs[0], '', capture.inspect)
    #			BranchReference.new_from_ref(refs[0]), :time => refs[3]} # unambiguous ref
    #    assert_equal(refs[0], br.to_s, br.inspect)
    # ?	assert_equal(refs[3] + ',' + refs[4], br.timestamp, br.inspect)
    # ?	assert_equal(refs[3] + ',' + refs[4], br.timestamp, br.inspect)
    #    assert_operator(Time.rfc2822(refs[4]), :==, br.timestamp, br.inspect) #

    new_from_ref = BranchReference.new_from_ref(Reflog_line)
    #    assert_equal(123, new_from_ref.age.value, Reflog_capture.output.inspect)
    #    assert_equal(123, new_from_ref[:age].value, Reflog_capture.inspect)
    # ?	assert_match(Regexp::Start_string * BranchReference::Unambiguous_ref_age_pattern * Regexp::End_string, Reflog_reference.age, message)
    # ?	assert_match(Regexp::Start_string * '123' * Regexp::End_string, Reflog_reference.age, message)
    BranchReference.assert_output(Reflog_line)
    BranchReference.assert_output(Last_change_line)
    BranchReference.assert_output(First_change_line)
    #    BranchReference.new_from_ref(No_ref_line).assert_pre_conditions
    #	assert_equal(nil, capture.output[:ambiguous_branch].nil?)
    #    BranchReference.new_from_ref(First_change_line).assert_pre_conditions
    #    BranchReference.new_from_ref(Last_change_line).assert_pre_conditions
    #    BranchReference.new_from_ref(Reflog_line).assert_pre_conditions

    #		assert_instance_of(Time, br.timestamp, br.inspect)

    branch = :master
    age = 123
    timestamp = Time.now
    br = BranchReference.new(name: branch, age: age, timestamp: timestamp.to_s)
    #    assert_equal(br, BranchReference.new_from_ref(Reflog_line))
  end # new_from_ref

  def test_to_s
    #	BranchReference.assert_output(Reflog_line)
    #    assert_equal(:master, BranchReference.new_from_ref(Reflog_line).name, Reflog_line)
    reflog_reference = BranchReference.new_from_ref(Reflog_line)
    message = reflog_reference.inspect
    #		assert_instance_of(Dry::Monads::Maybe::Some, reflog_reference.age, reflog_reference.inspect)
    #		assert_includes(reflog_reference.age.methods, :value, reflog_reference.inspect)
    #		assert_instance_of(Fixnum, reflog_reference.age.value, reflog_reference.inspect)
    #    assert_equal(123, reflog_reference.age.value, message)
    #    assert_equal('master@{123}', BranchReference.new_from_ref(Reflog_line).to_s)
    #    assert_equal('master@{123}', Reflog_reference.to_s)
  end # to_s

  def test_assert_reflog_line
    BranchReference.assert_reflog_line(Reflog_line)
    BranchReference.assert_reflog_line(Last_change_line)
    BranchReference.assert_reflog_line(First_change_line)
    BranchReference.assert_reflog_line(No_ref_line)
  end # reflog_line

  def test_assert_output
    BranchReference.assert_output(No_ref_line)
    BranchReference.assert_output(First_change_line)
    BranchReference.assert_output(Reflog_line)
    BranchReference.assert_output(Last_change_line)
  end # assert_output

  def test_Examples
    Reflog_run_executable.assert_post_conditions
    refute_nil(Reflog_lines)
    refute_empty(Reflog_lines, $PROGRAM_NAME + ' has not been added to git yet.')
    refute_nil(First_change_line)
    refute_nil(Last_change_line)
    reflog_reference = BranchReference.new_from_ref(Reflog_line)
  end # Examples
end # BranchReference

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
