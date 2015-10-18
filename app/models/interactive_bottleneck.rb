###########################################################################
#    Copyright (C) 2013-2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'unit.rb'
require_relative 'repository.rb'
require_relative 'unit_maturity.rb'
require_relative 'editor.rb'
class InteractiveBottleneck
module Constants
end # Constants
include Constants
module ClassMethods
include Constants
end # ClassMethods
extend ClassMethods
# Define related (unit) versions
# Use as current, lower/upper bound, branch history
# parametized by related files, repository, branch_number, executable
# record error_score, recent_test, time
attr_reader :related_files, :edit_files, :repository, :unit_maturity, :editor
def initialize(test_executable, editor = Editor.new(test_executable))
	@test_executable = test_executable
	@editor = editor
	@unit_maturity = UnitMaturity.new(@test_executable.repository, related_files)
	@related_files = related_files
	@repository = @test_executable.repository
	index = UnitMaturity::Branch_enhancement.index(@repository.current_branch_name?)
	if index.nil? then
		@branch_index = UnitMaturity::First_slot_index
	else
		@branch_index = index
	end # if
end # initialize
def standardize_position!
	 abort_rebase_and_merge!
	git_command("checkout master")
end #standardize_position!
def abort_rebase_and_merge!
	if File.exists?('.git/rebase-merge/git-rebase-todo') then
		git_command("rebase --abort")
	end
#	git_command("stash save").assert_post_conditions
	if File.exists?('.git/MERGE_HEAD') then
		git_command("merge --abort")
	end # if
end # abort_rebase_and_merge!
def state?
	state=[]
	if File.exists?('.git/rebase-merge/git-rebase-todo') then
		state << :rebase
	end
	if File.exists?('.git/MERGE_HEAD') then
		state << :merge
	end # if
	if something_to_commit? then
		state << :dirty
	else
		state << :clean
	end # if
	return state
end # state?
def merge_conflict_recovery(from_branch)
# see man git status
	puts '@repository.merge_conflict_files?= ' + @repository.merge_conflict_files?.inspect
	unmerged_files = @repository.merge_conflict_files?
	if !unmerged_files.empty? then
		puts 'merge --abort'
		merge_abort = @repository.git_command('merge --abort')
		if merge_abort.success? then
			puts 'merge --X ours ' + from_branch.to_s
			remerge = @repository.git_command('merge --X ours ' + from_branch.to_s)
		end # if
		unmerged_files.each do |conflict|
			if conflict[:file][-4..-1] == '.log' then
				@repository.git_command('checkout HEAD ' + conflict[:file])
				puts 'checkout HEAD ' + conflict[:file]
			else
				puts 'not checkout HEAD ' + conflict[:file]
				case conflict[:conflict]
				# DD unmerged, both deleted
				when 'DD' then fail Exception.new(conflict.inspect)
				# AU unmerged, added by us
				when 'AU' then fail Exception.new(conflict.inspect)
				# UD unmerged, deleted by them
				when 'UD' then fail Exception.new(conflict.inspect)
				# UA unmerged, added by them
				when 'UA' then fail Exception.new(conflict.inspect)
				# DU unmerged, deleted by us
				when 'DU' then fail Exception.new(conflict.inspect)
				# AA unmerged, both added
				# UU unmerged, both modified
				when 'UU', ' M', 'M ', 'MM', 'A ', 'AA' then
					WorkFlow.new(conflict[:file]).editor.edit('merge_conflict_recovery')
	#				@repository.validate_commit(@repository.current_branch_name?, [conflict[:file]])
				else
					fail Exception.new(conflict.inspect)
				end # case
			end # if
		end # each
		@repository.confirm_commit
	end # if
end # merge_conflict_recovery
def confirm_branch_switch(branch)
	checkout_branch=git_command("checkout #{branch}")
	if checkout_branch.errors!="Already on '#{branch}'\n" && checkout_branch.errors!="Switched to branch '#{branch}'\n" then
		checkout_branch #.assert_post_conditions
	end #if
	checkout_branch # for command chaining
end #confirm_branch_switch
# This is safe in the sense that a stash saves all files
# and a stash apply restores all tracked files
# safe is meant to mean no files or changes are lost or buried.
def safely_visit_branch(target_branch, &block)
	stash_branch = current_branch_name?
	changes_branch = stash_branch # 
	push=something_to_commit? # remember
	if push then
#		status=@grit_repo.status
#		puts "status.added=#{status.added.inspect}"
#		puts "status.changed=#{status.changed.inspect}"
#		puts "status.deleted=#{status.deleted.inspect}"
#		puts "something_to_commit?=#{something_to_commit?.inspect}"
		git_command('stash save --include-untracked')
		merge_conflict_files?.each do |conflict|
			shell_command('diffuse -m '+conflict[:file])
			confirm_commit
		end #each
		changes_branch=:stash
	end #if

	if stash_branch != target_branch then
		confirm_branch_switch(target_branch)
		ret=block.call(changes_branch)
		confirm_branch_switch(stash_branch)
	else
		ret=block.call(changes_branch)
	end #if
	if push then
		apply_run=git_command('stash apply --quiet')
		if apply_run.errors.match(/Could not restore untracked files from stash/) then
			puts apply_run.errors
			puts git_command('status').output
			puts git_command('stash show').output
		else
			apply_run #.assert_post_conditions('unexpected stash apply fail')
		end #if
		merge_conflict_files?.each do |conflict|
			shell_command('diffuse -m '+conflict[:file])
			confirm_commit
		end #each
	end #if
	ret
end #safely_visit_branch
# does not return to original branch unlike #safely_visit_branch
# does not need a block, since it doesn't switch back
# moves all working directory files to new branch
def switch_branch(target_branch)
	push = stash_and_checkout(target_branch)
end # switch_branch
def merge_interactive(source_branch)
		merge_status = git_command('merge --no-commit ' + source_branch.to_s)
end # merge_interactive
def stash_and_checkout(target_branch)
	stash_branch = current_branch_name?
	changes_branch = stash_branch # 
	push=something_to_commit? # remember
	if push then
#		status=@grit_repo.status
#		puts "status.added=#{status.added.inspect}"
#		puts "status.changed=#{status.changed.inspect}"
#		puts "status.deleted=#{status.deleted.inspect}"
#		puts "something_to_commit?=#{something_to_commit?.inspect}"
		git_command('stash save --include-untracked')
		merge_conflict_files?.each do |conflict|
			shell_command('diffuse -m '+conflict[:file])
			confirm_commit
		end #each
		changes_branch=:stash
	end #if

	if stash_branch != target_branch then
		confirm_branch_switch(target_branch)
	end #if
	push # if switched?
end # stash_and_checkout
def merge_cleanup(editor)
	merge_conflict_files?.each do |conflict|
		shell_command('diffuse -m '+conflict[:file])
		confirm_commit
	end #each
end # merge_cleanup
def merge(target_branch, source_branch, interact=:interactive)
	puts 'merge('+target_branch.inspect+', '+source_branch.inspect+', '+interact.inspect+')'
	@repository.safely_visit_branch(target_branch) do |changes_branch|
		merge_status = @repository.git_command('merge --no-commit ' + source_branch.to_s)
		puts 'merge_status= ' + merge_status.inspect
		if merge_status.output == "Automatic merge went well; stopped before committing as requested\n" then
			puts 'merge OK'
		else
			if merge_status.success? then
				puts 'not merge_conflict_recovery' + merge_status.inspect
			else
				puts 'merge_conflict_recovery' + merge_status.inspect
				merge_conflict_recovery(source_branch)
			end # if
		end # if
		@repository.confirm_commit(interact)
	end # safely_visit_branch
end # merge
def merge_down(deserving_branch = @repository.current_branch_name?)
	UnitMaturity.merge_range(deserving_branch).each do |i|
		@repository.safely_visit_branch(UnitMaturity::Branch_enhancement[i]) do |changes_branch|
			puts 'merge(' + UnitMaturity::Branch_enhancement[i].to_s + '), ' + UnitMaturity::Branch_enhancement[i - 1].to_s + ')' if !$VERBOSE.nil?
			merge(UnitMaturity::Branch_enhancement[i], UnitMaturity::Branch_enhancement[i - 1])
			merge_conflict_recovery(UnitMaturity::Branch_enhancement[i - 1])
			@repository.confirm_commit(:interactive)
		end # safely_visit_branch
	end # each
end # merge_down
def stage_files(branch, files)
	safely_visit_branch(branch) do |changes_branch|
		validate_commit(changes_branch, files)
	end #safely_visit_branch
end #stage_files
def confirm_commit(interact=:interactive)
	if something_to_commit? then
		case interact
		when :interactive then
			cola_run = git_command('cola')
			cola_run = cola_run.tolerate_status_and_error_pattern(0, /Warning/)
			cola_run #.assert_post_conditions
			if !something_to_commit? then
#				git_command('cola rebase '+current_branch_name?.to_s)
			end # if
		when :echo then
		when :staged then
			git_command('commit ').assert_post_conditions			
		when :all then
			git_command('add . ').assert_post_conditions
			git_command('commit ').assert_post_conditions
		else
			raise 'Unimplemented option=' + interact.to_s
		end #case
	end #if
	puts 'confirm_commit('+interact.inspect+" something_to_commit?="+something_to_commit?.inspect
end # confirm_commit
def validate_commit(changes_branch, files, interact=:interactive)
	puts files.inspect if $VERBOSE
	files.each do |p|
		puts p.inspect  if $VERBOSE
		git_command(['checkout', changes_branch.to_s, p])
	end #each
	if something_to_commit? then
		confirm_commit(interact)
#		git_command('rebase --autosquash --interactive')
	end #if
end #validate_commit
def script_deserves_commit!(deserving_branch)
	if working_different_from?($PROGRAM_NAME, 	UnitMaturity.branch_index?(deserving_branch)) then
		repository.stage_files(deserving_branch, related_files.tested_files($PROGRAM_NAME))
		merge_down(deserving_branch)
	end # if
end # script_deserves_commit!
require_relative '../../test/assertions.rb'
module Assertions

module ClassMethods

def assert_pre_conditions
end # assert_pre_conditions
def assert_post_conditions
#	assert_pathname_exists(TestExecutable, "assert_post_conditions")
end # assert_post_conditions
end # ClassMethods
def assert_pre_conditions
	refute_nil(@related_files)
	refute_empty(@related_files.edit_files, "assert_pre_conditions, @test_environmen=#{@test_environmen.inspect}, @related_files.edit_files=#{@related_files.edit_files.inspect}")
	assert_kind_of(Grit::Repo, @repository.grit_repo)
	assert_respond_to(@repository.grit_repo, :status)
	assert_respond_to(@repository.grit_repo.status, :changed)
end # assert_pre_conditions
def assert_post_conditions
	odd_files = Dir['/home/greg/Desktop/src/Open-Table-Explorer/test/unit/*_test.rb~HEAD*']
	assert_empty(odd_files, 'WorkFlow#assert_post_conditions')
end # assert_post_conditions
end # Assertions
include Assertions
extend Assertions::ClassMethods
# TestWorkFlow.assert_pre_conditions
include Constants
module Examples
TestExecutable = TestExecutable.new(executable_file: File.expand_path($PROGRAM_NAME))
TestInteractiveBottleneck = InteractiveBottleneck.new(TestExecutable, Editor::Examples::TestEditor)
include Constants
end # Examples
include Examples
end # InteractiveBottleneck