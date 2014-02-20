###########################################################################
#    Copyright (C) 2012-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/minimal2.rb'
class PushSummaryTest < TestCase
include DefaultTests
include TE.model_class?::Examples
def test_rebase
			if !something_to_commit? then
				git_command('cola rebase origin/'+current_branch_name?.to_s)
			end # if
end #
end #Rebase
