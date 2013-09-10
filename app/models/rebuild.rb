###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class Rebuild
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
	if File.exists?(@path) then
		command_string='rsync '+Shellwords.escape(source_path)+' '+Shellwords.escape(temporary_path)
		ShellCommands.new(command_string).assert_post_conditions #uncorrupted old backup to start
	else
		command_string='cp -a '+Shellwords.escape(source_path)+' '+Shellwords.escape(temporary_path)
		ShellCommands.new(command_string).assert_post_conditions #uncorrupted old backup to start
	end #if
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
def fetch_commits(name, commit, repository_file)
	Clean_Example.git_command("fetch file://"+repository+" "+name)
end #fetch_commits
def initialize_branch(name, commit, repository_file)
	Clean_Example.git_command("fetch file://"+repository+" "+name)
	Clean_Example.git_command("symbolic-link #{name.to_s} "+commit.to_s).assert_post_conditions
end #initialize_branch

def add_commits(from_repository, last_commit_to_add, branch, history_options='--squash -Xthiers ')
	Clean_Example.git_command("fetch file://"+repository+" "+name)
	Clean_Example.git_command("checkout  #{branch}").assert_post_conditions
	Clean_Example.git_command("merge #{history_options} "+" -m "+name.to_s+commit.to_s).assert_post_conditions
end #add_commits
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
Source='/media/greg/SD_USB_32G/Repository Backups/'
end #Examples
include Examples
end #Rebuild


