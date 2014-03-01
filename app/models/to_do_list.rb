###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class ToDoList
module ClassMethods
end #ClassMethods
extend ClassMethods
module Constants
Hex_number=/[0-9a-f]+/
end #Constants
include Constants
# attr_reader
# onto origin/<branch> for default
#        String =>previous commit starts rebase ('--root' possible)
def initialize(branch, onto=branch.remote_branch)
	@branch=branch
	if onto.instance_of?(Fixnum) then
		@onto=@branch + '~' + onto.to_s
	
	else
		@onto=onto
	end # if
end #initialize
def todo_list
	git_command('git shortlog '+find_origin+'..'+@branch.to_s).output
end # todo_list
def flip_start_fixup
	todo_cache=todo_list # relatively expensive call
	squashable_list=todo_cache[0]
	todo_cache.cons(2) do |consecutive_lines|
		previous_commit=consecutive_lines[0]
		fixup_header=consecutive_lines[1]
		if fixup_header!=previous_commit then # change
			squashable_list << fixup_header.gsub(/fixup! |squash! /, '') # delete header on first
		else
			squashable_list << consecutive_lines[1]
		end # if
	end # map
end # flip_start_fixup
def fixup_until_fail
	run=git_command('git rebase --continue')
end # fixup_until_fail
def rebase!
	if remotes?.include?(current_branch_name?) then
		git_command('rebase --interactive origin/'+current_branch_name?).assert_post_conditions.output.split("\n")
	else
		puts current_branch_name?.to_s+' has no remote branch in origin.'
	end #if
end #rebase!
def cola_rebase!
		git_command('cola rebase ' + @branch.to_s + ' --onto ' + @onto.to_s).assert_post_conditions.output.split("\n")
end # 
def command_line_rebase!
		git_command('rebase --interactive '+ @branch.to_s + ' --onto ' + @onto.to_s).assert_post_conditions.output.split("\n")
end # command_line_rebase!
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
end #Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants

end #Examples
end # ToDoList
