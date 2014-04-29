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
include TE.model_class?::Examples
include Repository::Examples
#include Branch::Examples
def test_initialize
end # initialize
def test_todo_list
end # todo_list
def test_flip_start_fixup
end # flip_start_fixup
def test_fixup_until_fail
end # fixup_until_fail
def test_rebase_editor?
	assert_equal('GIT_SEQUENCE_EDITOR=emacs', Test_rebase.rebase_editor?)
end #rebase_editor?
def test_rebase
			if !This_code_repository.something_to_commit? then
#				This_code_repository.git_command('cola rebase origin/'+This_code_repository.current_branch_name?.to_s)
			end # if
	empty_repo_master_branch=Branch.new(Empty_Repo, :master)
#	test_rebase = Test_rebase.rebase!
end #rebase!
def test_command_line_rebase_string?
	assert_equal('git rebase master --onto master~4', 					 Test_rebase_4.command_line_rebase_string?)
	assert_equal('git rebase --interactive master --onto master~4', Executing_rebase_4.command_line_rebase_string?)
	assert_equal('git rebase master --onto passed', 					 Test_rebase_passed.command_line_rebase_string?)
	assert_equal('git rebase --interactive master --onto passed', 	 Executing_rebase_passed.command_line_rebase_string?)
#	assert_equal('git rebase master --onto origin/master', 					 Test_rebase.command_line_rebase_string?)
#	assert_equal('git rebase --interactive master --onto /originmaster', 	 Executing_rebase.command_line_rebase_string?)
end # command_line_rebase!
end #ToDoList
