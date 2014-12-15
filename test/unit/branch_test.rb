###########################################################################
#    Copyright (C) 2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative '../../test/assertions/ruby_assertions.rb'
require_relative '../../test/assertions/repository_assertions.rb'
class BranchTest < TestCase
include DefaultTests
include Repository::Examples
Minimal_repository=Empty_Repo
def test_current_branch_name?
#	assert_include(WorkFlow::Branch_enhancement, Repo.head.name.to_sym, Repo.head.inspect)
#	assert_include(WorkFlow::Branch_enhancement, WorkFlow.current_branch_name?, Repo.head.inspect)

end #current_branch_name
def test_branches?
	assert_equal(:master, Empty_Repo.current_branch_name?)
#?	explain_assert_respond_to(Parse, :parse_split)
	branch_output = Empty_Repo.git_command('branch --list').assert_post_conditions.output
	patterns.each do |p|
		assert_match(p, branch_output)
		branches=Parse.parse_into_array(branch_output, p, {ending: :optional})
		assert_equal([{:branch=>"master"}, {:branch=>"passed"}], branches, branch_output.inspect)
	end # each
	
	assert_includes(Empty_Repo.branches?.map{|b| b.branch}, Empty_Repo.current_branch_name?)
	assert_equal([:master, :passed], Empty_Repo.branches?.map{|b| b.branch})
	assert_includes(This_code_repository.branch_names?.map{|b| b.branch}, This_code_repository.current_branch_name?)
end #branches?
def test_remotes?
	assert_includes(This_code_repository.remotes?, "origin/"+Empty_Repo.current_branch_name?.to_s)
	assert_empty(Empty_Repo.remotes?)
	assert_not_empty(This_code_repository.remotes_names?)
end #remotes?
									' -> ', Branch_name_regexp.capture(:referenced), Regexp::Optional]
end #Repository
