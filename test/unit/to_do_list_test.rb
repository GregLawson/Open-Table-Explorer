###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative '../../app/models/to_do_list.rb'
require_relative '../../test/assertions/repository_assertions.rb'
class ToDoListTest < TestCase
include DefaultTests
#include TE.model_class?::Examples
include Repository::Examples
def test_initialize
end # initialize
def test_todo_list
end # todo_list
def test_flip_start_fixup
end # flip_start_fixup
def test_fixup_until_fail
end # fixup_until_fail
def test_rebase
			if !This_code_repository.something_to_commit? then
#				This_code_repository.git_command('cola rebase origin/'+This_code_repository.current_branch_name?.to_s)
			end # if
end #
def test_rebase!
#	Empty_Repo.rebase!
end #rebase!
end #ToDoList
