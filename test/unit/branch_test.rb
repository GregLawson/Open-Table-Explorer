###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
#require_relative '../../app/models/branch.rb'
require_relative '../../test/assertions/branch_assertions.rb'
class BranchTest < TestCase
include DefaultTests
#include TE.model_class?::Examples
include Repository::Examples
def test_initialize
	assert_equal(This_code_repository, Branch.new(This_code_repository).repository)

	branch=This_code_repository.current_branch_name?
	onto=Branch::Examples::Executing_branch.find_origin
end # initialize
def test_find_origin
end # find_origin
def test_Constants
	assert_equal(This_code_repository, Branch::Examples::Executing_branch.repository)
end #Constants
end #Rebase
