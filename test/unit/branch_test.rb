###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/branch.rb'
require_relative '../../test/assertions/repository_assertions.rb'
class BranchTest < TestCase
include DefaultTests
#include TE.model_class?::Examples
include Repository::Examples
def test_branches?
	assert_equal(:master, Empty_Repo.current_branch_name?)
#?	explain_assert_respond_to(Parse, :parse_split)
	branch_output=Empty_Repo.git_command('branch --list').assert_post_conditions.output
	pattern = /[* ]/*/[a-z0-9A-Z_-]+/.capture(:branch)*/\n/
	patterns = [Branch::Constants::Branch_regexp,
					/[* ]/*/ /*/[-a-z0-9A-Z_]+/.capture(:branch),
					/^[* ] /*/[a-z0-9A-Z_-]+/.capture(:branch),
					pattern]
	patterns.each do |p|
		assert_match(branch_output, p)
		branches=Parse.parse_into_array(branch_output, p, {ending: :optional})
		assert_equal([{:branch=>"master"}, {:branch=>"passed"}], branches, branch_output.inspect)
	end # each
	
	assert_includes(Empty_Repo.branches?.map{|b| b.branch}, Empty_Repo.current_branch_name?)
	assert_equal([:master, :passed], Empty_Repo.branches?.map{|b| b.branch})
	assert_includes(This_code_repository.branches?.map{|b| b.branch}, This_code_repository.current_branch_name?)
end #branches?
def test_remotes?
	assert_includes(This_code_repository.remotes?, "  origin/"+Empty_Repo.current_branch_name?.to_s)
end #remotes?
def test_Constants
	assert_equal(This_code_repository, Branch::Executing_branch.repository)
end #Constants
def test_initialize
	assert_equal(This_code_repository, Branch.new(This_code_repository).repository)
	assert_equal(This_code_repository, Branch.new.repository)

	branch=This_code_repository.current_branch_name?
	onto=Branch::Executing_branch.find_origin
end # initialize
def test_find_origin
end # find_origin
end #Rebase
