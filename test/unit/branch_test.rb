###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../test/assertions/ruby_assertions.rb'
#require_relative '../../test/assertions/repository_assertions.rb'
require_relative '../../app/models/branch.rb'
class BranchTest < TestCase
include DefaultTests
include Repository::Examples
include Branch::Constants
Minimal_repository=Empty_Repo
def test_branch_command?
	repository = Empty_Repo
	git_command = 'branch --list'
	branch_output = repository.git_command(git_command).assert_post_conditions.output
	parse = branch_output.parse(Branch_regexp)
end # branch_command?
def test_current_branch_name?
#	assert_include(WorkFlow::Branch_enhancement, WorkFlow.current_branch_name?, Repo.head.inspect)
	branch_output= Empty_Repo.git_command('branch --list').assert_post_conditions.output
	assert_equal(:master, Branch.current_branch_name?(Empty_Repo))
end #current_branch_name
def test_branches?
#?	explain_assert_respond_to(Parse, :parse_split)
	branch_output = Empty_Repo.git_command('branch --list').assert_post_conditions.output
	Patterns.each do |p|
		assert_match(p, branch_output)
		branches=branch_output.parse(p)
		assert_equal([{:branch=>"master"}, {:branch=>"passed"}], branches, p.inspect)
	end # each
	
	assert_includes(Empty_Repo.branches?.map{|b| b.branch}, Empty_Repo.current_branch_name?)
	assert_equal([:master, :passed], Empty_Repo.branches?.map{|b| b.branch})
	assert_includes(This_code_repository.branch_names?.map{|b| b.branch}, This_code_repository.current_branch_name?)
end #branches?
def test_remotes?
	assert_empty(Empty_Repo.remotes?)
end #remotes?
def test_initialize
	assert_equal(This_code_repository, Branch.new(This_code_repository).repository)

	branch=This_code_repository.current_branch_name?
	onto=Branch::Examples::Executing_branch.find_origin
end # initialize
end #Repository
