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
Root_directory=FilePattern.project_root_dir?
Source=File.dirname(Root_directory)+'/'
end #Constants
module ClassMethods
def create_empty(path)
	ShellCommands.new('mkdir '+path)
	ShellCommands.new('cd '+path+';git init')
	new_repository=Repository.new(path)
	IO.write(path+'/README', 'Smallest possible repository.') # two consecutive slashes = one slash
	new_repository.git_command('add README')
	new_repository.git_command('commit -m "initial commit of README"')
end #create_empty
def create_if_missing(path)
	if File.exists?(path) then
		Repository.new(path)
	else
		create_empty(path)
	end #if
end #create_if_missing
end #ClassMethods
extend ClassMethods
require_relative "shell_command.rb"
attr_reader :path, :grit_repo
def initialize(path)
	@url=path
	@path=path
	source_path=@path
	temporary_path=Temporary+'recover'
  puts '@path='+@path if $VERBOSE
	@grit_repo=Grit::Repo.new(@path)
end #initialize
def shell_command(command, working_directory=Shellwords.escape(@path))
		ret=ShellCommands.new("cd #{working_directory}; #{command}")
		ret.puts if $VERBOSE
		ret
end #shell_command
def git_command(git_subcommand)
	ret=shell_command("git "+git_subcommand)
	if $VERBOSE && git_subcommand != 'status' then
		shell_command("git status").puts
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
end #current_branch_name
def deserving_branch?(executable=@related_files.model_test_pathname?)
	test=shell_command("ruby "+executable)
	test.puts if $VERBOSE
	if test.success? then
		:passed
	elsif test.exit_status==1 then # 1 error or syntax error
		:edited
	else
		:testing
	end #if
end #deserving_branch
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
def stage(target_branch, tested_files)
	if current_branch_name? ==target_branch then
		push_branch=target_branch # no need for stash popping
	else
		push_branch=current_branch_name?
		git_command("stash save").assert_post_conditions
		switch_branch=git_command("checkout "+target_branch.to_s).execute
		message="#{current_branch_name?.inspect}!=#{target_branch.inspect}\n"
		message+="current_branch_name? !=target_branch=#{current_branch_name? !=target_branch}\n"
		tested_files.each do |p|
			git_command("checkout stash "+p).execute.assert_post_conditions
		end #each
		if !switch_branch.errors.empty? then
			puts "Why am I here?"+message
			switch_branch.puts
		end #if
	end #if
	git_command("add "+tested_files.join(' ')).execute.assert_post_conditions	
	git_command('cola').assert_post_conditions
	push_branch
end #stage
def commit_to_branch(target_branch, tested_files)
	push_branch=stage(target_branch, tested_files)
	if push_branch!=target_branch then
		git_command("checkout "+push_branch.to_s).execute.assert_post_conditions
		git_command("checkout stash apply").execute.assert_post_conditions
	end #if
end #commit_to_branch
def test_and_commit(executable, tested_files)
	
	commit_to_branch(deserving_branch?(executable), tested_files)

end #test
def Stash_Pop
	git_command("stash pop")
end #
def CompilesSupersetOfMaster
	git_command("log compiles..master")
end #
def DevelopmentSupersetofCompiles
	git_command("log development..compiles")
end #
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
include Constants
module Examples
include Constants
Removable_Source='/media/greg/SD_USB_32G/Repository Backups/'
Repo= Grit::Repo.new(Root_directory)
SELF_code_Repo=Repository.new(Root_directory)
Empty_Repo=Repository.new(Source+'test_recover/')
end #Examples
include Examples
end #Repository


