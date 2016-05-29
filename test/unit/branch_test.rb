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
  def test_BranchReference_DefinitionalConstants
    BranchReference.assert_reflog_line(Reflog_line)
    BranchReference.assert_reflog_line(Last_change_line)
    BranchReference.assert_reflog_line(First_change_line)
    Reflog_lines.each do |reflog_line|
      BranchReference.assert_reflog_line(reflog_line)
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
    assert_equal(refs[2].to_sym, br.name, br.inspect)
    # Now test one with refs
    reflog_line = Last_change_line
    capture = reflog_line.capture?(BranchReference::Reflog_line_regexp)
    #	Test method
    br = BranchReference.new_from_ref(reflog_line)
    br = BranchReference.new_from_ref(reflog_line)
    refs = reflog_line.split(',')
    refute_equal(refs[0], '', capture.inspect)
    #			BranchReference.new_from_ref(refs[0]), :time => refs[3]} # unambiguous ref
    assert_equal(refs[0], br.to_s, br.inspect)
    # ?	assert_equal(refs[3] + ',' + refs[4], br.timestamp, br.inspect)
    # ?	assert_equal(refs[3] + ',' + refs[4], br.timestamp, br.inspect)
    assert_operator(Time.rfc2822(refs[4]), :==, br.timestamp, br.inspect) #
    branch = :master
    age = 123
    br = BranchReference.new(branch: branch, age: age)
    new_from_ref = BranchReference.new_from_ref(Reflog_line)
    assert_equal(123, new_from_ref.age, Reflog_capture.output.inspect)
    assert_equal(123, new_from_ref[:age], Reflog_capture.inspect)
    # ?	assert_equal(br, BranchReference.new_from_ref(Reflog_line))
    # ?	assert_match(Regexp::Start_string * BranchReference::Unambiguous_ref_age_pattern * Regexp::End_string, Reflog_reference.age, message)
    # ?	assert_match(Regexp::Start_string * '123' * Regexp::End_string, Reflog_reference.age, message)
    BranchReference.assert_output(Reflog_line)
    BranchReference.assert_output(Last_change_line)
    BranchReference.assert_output(First_change_line)
    BranchReference.new_from_ref(No_ref_line).assert_pre_conditions
    #	assert_equal(nil, capture.output[:ambiguous_branch].nil?)
    BranchReference.new_from_ref(First_change_line).assert_pre_conditions
    BranchReference.new_from_ref(Last_change_line).assert_pre_conditions
    Reflog_reference.assert_pre_conditions
  end # new_from_ref

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
      BranchReference.new_from_ref(reflog_line)
      #		new(capture.output[:ambiguous_branch].to_sym,capture.output[:age].to_i)
    end # map
    reflog = BranchReference.reflog?(filename, This_code_repository)
    #	assert_equal(manual_reflog, reflog, reflog.inspect)
    refute_equal([], reflog, BranchReference.reflog_command_string(filename, repository, range = 0..10).inspect)
    #	reflog.assert_post_conditions
    #	refute_empty(reflog.output)
    ##	lines = reflog.output.split("\n")
    #	assert_instance_of(Array, reflog)
    #	assert_operator(reflog.size, :>,1, reflog)
    #	assert_equal('', reflog[0], lines)
  end # reflog?

  def test_last_change?
    filename = $PROGRAM_NAME
    repository = @temp_repo
    reflog = BranchReference.reflog?(filename, repository)
    assert_equal(nil, BranchReference.last_change?(filename, repository))
    #	assert_includes(Branch.branch_names?(This_code_repository), BranchReference.last_change?(filename, This_code_repository).name)
  end # last_change?

  def test_to_s
    #	BranchReference.assert_output(Reflog_line)
    assert_equal(:master, BranchReference.new_from_ref(Reflog_line).name, Reflog_line)
    message = Reflog_reference.inspect
    assert_equal(123, Reflog_reference.age, message)
    assert_equal('master@{123}', BranchReference.new_from_ref(Reflog_line).to_s)
    assert_equal('master@{123}', Reflog_reference.to_s)
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

  def test_Branch_Constants
  end # Constants

  def test_branch_symbol?
    assert_equal(:master, Branch.branch_symbol?(-1))
    assert_equal(:passed, Branch.branch_symbol?(0))
    assert_equal(:testing, Branch.branch_symbol?(1))
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
    assert_equal(1, Branch.branch_index?(:testing))
    assert_equal(2, Branch.branch_index?(:edited))
    assert_equal(3, Branch.branch_index?(:stash))
    assert_equal(4, Branch.branch_index?(:'stash~1'))
    assert_equal(5, Branch.branch_index?(:'stash~2'))
    assert_equal(-1, Branch.branch_index?(:master))
    assert_equal(-3, Branch.branch_index?(:work_flow))
    assert_equal(-2, Branch.branch_index?(:tax_form))
    assert_equal(-4, Branch.branch_index?(:'origin/master'))
    assert_equal(nil, Branch.branch_index?('/home/greg'))
  end # branch_index?

  def test_merge_range
    assert_equal(1..2, Branch.merge_range(:passed))
    assert_equal(2..2, Branch.merge_range(:testing))
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
      puts branches.inspect if branches.success?
      # ?		assert_equal([{:branch=>"master"}, {:branch=>"passed"}], branches.output, branches.inspect)
    end # each

    assert_includes(Branch.branches?(@temp_repo).map(&:name), @temp_repo.current_branch_name?)
    #	assert_includes(Branch.branches?(Repository::This_code_repository).map{|b| b.name}, Repository::This_code_repository.current_branch_name?)
    # ?	assert_equal([:master, :passed], Branch.branches?(@temp_repo).map{|b| b.name})
    # ?	assert_includes(Branch.branch_names?(This_code_repository), This_code_repository.current_branch_name?)
  end # branches?

  def test_remotes?
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
    assert_equal('-r testing', Branch.revison_tag?(1))
    assert_equal('-r edited', Branch.revison_tag?(2))
    assert_equal('-r stash', Branch.revison_tag?(3))
    assert_equal('-r stash~1', Branch.revison_tag?(4))
    assert_equal('-r stash~2', Branch.revison_tag?(5))
    assert_equal('-r work_flow', Branch.revison_tag?(-3))
    assert_equal('-r origin/master', Branch.revison_tag?(-4))
  end # revison_tag?

  def test_initialize
    assert_equal(This_code_repository, Branch.new(repository: This_code_repository).repository)

    branch = This_code_repository.current_branch_name?
    onto = Branch::Examples::Executing_branch.find_origin
  end # initialize

  def test_compare
    sorted_branches = Branch.branches?(Repository::This_code_repository).sort.map(&:name)
    #	assert_equal([], sorted_branches)

    assert_operator(sorted_branches[0], :==, sorted_branches[0])
  end # compare
end # Branch
