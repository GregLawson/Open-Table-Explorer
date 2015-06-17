###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../test/assertions/branch_assertions.rb'
#require_relative '../../test/assertions/repository_assertions.rb'
require_relative '../../app/models/branch.rb'
class BranchTest < TestCase
include DefaultTests
include Repository::Examples
include Branch::Constants
include Branch::Examples
def test_new_from_ref
	assert_equal(BranchReference.new(:master, 123), BranchReference.new_from_ref('master@{123}'))
end # new_from_ref
def test_reflog?
#	reflog?(filename).output.split("/n")[0].split(',')[0]
	filename = $0
	reflog = BranchReference.reflog?(filename)
#	reflog.assert_post_conditions
#	assert_not_empty(reflog.output)
#	lines = reflog.output.split("\n")
	assert_instance_of(Array, reflog)
	assert_operator(reflog.size, :>,1, reflog)
#	assert_equal('', reflog[0], lines)
end # reflog?
def test_last_change?
	filename = $0
	repository = Empty_Repo
	reflog = BranchReference.reflog?(filename, repository)
	assert_equal(nil, BranchReference.last_change?(filename, repository))
	last_change = BranchReference.last_change?(filename, This_code_repository)
	assert_match(BranchReference::Unambiguous_ref_pattern, last_change)
	capture = last_change.capture?(BranchReference::Unambiguous_ref_pattern)
	assert_equal({}, capture)
	assert_includes([], BranchReference.last_change?(filename, This_code_repository))
end # last_change?
def test_branch_command?
	repository = Empty_Repo
	git_command = 'branch --list'
	branch_output = repository.git_command(git_command).assert_post_conditions.output
	parse = branch_output.parse(Branch_regexp)
end # branch_command?
def test_current_branch_name?
#	assert_include(UnitMaturity::Branch_enhancement, WorkFlow.current_branch_name?, Repo.head.inspect)
	branch_output= Empty_Repo.git_command('branch --list').assert_post_conditions.output
	assert_equal([:master, :passed], Branch.current_branch_name?(Empty_Repo))
end #current_branch_name
def test_branches?
#?	explain_assert_respond_to(Parse, :parse_split)
	branch_output = Empty_Repo.git_command('branch --list').assert_post_conditions.output
	Patterns.each do |p|
		assert_match(p, branch_output)
		branches = branch_output.capture?(p)
		puts branches.inspect if branches.success?
		assert_equal([{:branch=>"master"}, {:branch=>"passed"}], branches.output?, branches.inspect)
	end # each
	
	assert_includes(Branch.branches?(Empty_Repo).map{|b| b.branch}, Empty_Repo.current_branch_name?)
	assert_equal([:master, :passed], Branch.branches?(Empty_Repo).map{|b| b.branch})
	assert_includes(Branch.branch_names?(This_code_repository), This_code_repository.current_branch_name?)
end #branches?
def test_remotes?
	assert_empty(Branch.remotes?(Empty_Repo))
end # remotes?
def test_initialize
	assert_equal(This_code_repository, Branch.new(This_code_repository).repository)

	branch=This_code_repository.current_branch_name?
	onto=Branch::Examples::Executing_branch.find_origin
end # initialize
end # Branch
