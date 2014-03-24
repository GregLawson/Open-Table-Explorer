###########################################################################
#    Copyright (C) 2012-2014 by Greg Lawson                                      
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
include TE.model_class?::Examples
include Repository::Examples
def test_rebase
			if !This_code_repository.something_to_commit? then
				This_code_repository.git_command('cola rebase origin/'+This_code_repository.current_branch_name?.to_s)
			end # if
end #
end #Rebase
