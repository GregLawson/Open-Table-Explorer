###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'grit'  # sudo gem install grit
require_relative 'shell_command.rb'
class Repository
module Constants
Temporary='/mnt/working/Recover'
end #Constants
module ClassMethods
end #ClassMethods
extend ClassMethods
require_relative "shell_command.rb"
#subshell (cd_command=ShellCommands.new("cd #{Temporary}recover")).assert_post_conditions
#puts "cd_command=#{cd_command.inspect}"
def initialize(url)
	@url=url
	@path=url
	source_path=@path
	temporary_path=Temporary+'recover'
	@grit_repo=Grit::Repo.new(@path)
end #initialize
def git_command(git_subcommand)
	ret=ShellCommands.new("cd #{Shellwords.escape(@path)}; git "+git_subcommand)
	if $VERBOSE && git_subcommand != 'status' then
		ShellCommands.new("cd #{Shellwords.escape(@path)}; git status").inspect
	end #if
	ret
end #git_command
def standardize_position
	git_command("rebase --abort")
	git_command("merge --abort")
	git_command("stash save").assert_post_conditions
	git_command("checkout master")
end #standardize_position
def current_branch_name?
	@grit_repo.head.name.to_sym
end #branch
def deserving_branch?(executable=related_files.model_test_pathname?)
	test=ShellCommands.new("ruby "+executable, :delay_execution)
	test.execute
	if test.success? then
		:master
	elsif test.exit_status==1 then # 1 error or syntax error
		:development
	else
		:compiles
	end #if
end #
def upgrade_commit(target_branch, executable)
	target_index=WorkFlow::Branch_enhancement.index(target_branch)
	WorkFlow::Branch_enhancement.each_index do |b, i|
		commit_to_branch(b, executable) if i >= target_index
	end #each
end #upgrade_commit
def downgrade_commit(target_branch, executable)
	commit_to_branch(target_branch, executable)
end #downgrade_commit
def test(executable=related_files.model_test_pathname?)
	stage(deserving_branch?(executable), executable)
end #test
def upgrade(executable=related_files.model_test_pathname?)
	upgrade_commit(deserving_branch?(executable), executable)
end #upgrade
def best(executable=related_files.model_test_pathname?)
	upgrade_commit(deserving_branch?(executable), executable)
end #best
def downgrade(executable=related_files.model_test_pathname?)
	downgrade_commit(deserving_branch?(executable), executable)
end #downgrade
def stage(target_branch, executable)
	if WorkFlow.current_branch_name? ==target_branch then
		push_branch=target_branch # no need for stash popping
	else
		push_branch=WorkFlow.current_branch_name?
		Stash_Save.execute.assert_post_conditions
		switch_branch=ShellCommands.new("git checkout "+target_branch.to_s).execute
		message="#{WorkFlow.current_branch_name?.inspect}!=#{target_branch.inspect}\n"
		message+="WorkFlow.current_branch_name? !=target_branch=#{WorkFlow.current_branch_name? !=target_branch}\n"
		tested_files(executable).each do |p|
			ShellCommands.new("git checkout stash "+p).execute.assert_post_conditions
		end #each
		switch_branch.puts.assert_post_conditions(message)
	end #if
	ShellCommands.new("git add "+tested_files(executable).join(' ')).execute.assert_post_conditions	
	Git_Cola.execute.assert_post_conditions
	push_branch
end #stage
def commit_to_branch(target_branch, executable)
	push_branch=stage(target_branch, executable)
	if push_branch!=target_branch then
		ShellCommands.new("git checkout "+push_branch.to_s).execute.assert_post_conditions
		ShellCommands.new("git checkout stash pop").execute.assert_post_conditions
	end #if
end #commit_to_branch
def test_and_commit(executable)
	test=ShellCommands.new("ruby "+executable, :delay_execution)
	test.execute
	if test.success? then
		commit_to_branch(:master, executable)
	elsif test.exit_status==1 then # 1 error or syntax error
		commit_to_branch(:development, executable)
	else
		commit_to_branch(:compiles, executable)
	end #if
end #test
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
end #assert_pre_conditions
def assert_post_conditions
end #assert_post_conditions
end #Assertions
include Assertions
#TestWorkFlow.assert_pre_conditions
Stash_Save=ShellCommands.new("git stash save", :delay_execution)
Stash_Pop=ShellCommands.new("git stash pop", :delay_execution)
Git_status=ShellCommands.new("git status", :delay_execution)
Master_Checkout=ShellCommands.new("git checkout master", :delay_execution)
Compiles_Checkout=ShellCommands.new("git checkout compiles", :delay_execution)
Development_Checkout=ShellCommands.new("git checkout development", :delay_execution)
CompilesSupersetOfMaster=ShellCommands.new("git log compiles..master", :delay_execution)
DevelopmentSupersetofCompiles=ShellCommands.new("git log development..compiles", :delay_execution)
Root_directory=FilePattern.project_root_dir?
Repo= Grit::Repo.new(Root_directory)
include Constants
module Examples
include Constants
Source='/media/greg/SD_USB_32G/Repository Backups/'
end #Examples
include Examples
end #Repository


