###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/push_summary.rb'
require_relative '../../test/assertions/repository_assertions.rb'
class PushSummaryTest < TestCase
include DefaultTests
#include TE.model_class?::Examples
include Repository::Examples
def test_branches?
	assert_equal(:master, Empty_Repo.current_branch_name?)
#?	explain_assert_respond_to(Parse, :parse_split)
	assert_includes(This_code_repository.branches?, This_code_repository.current_branch_name?.to_s)
	assert_includes(Empty_Repo.branches?, Empty_Repo.current_branch_name?.to_s)
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
