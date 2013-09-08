###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
class Minimal
module ClassMethods
end #ClassMethods
extend ClassMethods
require_relative "shell_command.rb"
#subshell (cd_command=ShellCommands.new("cd #{Temporary}recover")).assert_post_conditions
#puts "cd_command=#{cd_command.inspect}"
def fetch_commits(name, commit, repository_file)
	ShellCommands.new("git fetch file://"+repository+" "+name)
end #fetch_commits
def initialize_branch(name, commit, repository_file)
	ShellCommands.new("git fetch file://"+repository+" "+name)
	ShellCommands.new("git symbolic-link #{name.to_s} "+commit.to_s).assert_post_conditions
end #initialize_branch

def add_commits(from_repository, last_commit_to_add, branch, history_options='--squash -Xthiers ')
	ShellCommands.new("git fetch file://"+repository+" "+name)
	ShellCommands.new("git checkout  #{branch}").assert_post_conditions
	ShellCommands.new("git merge #{history_options} "+" -m "+name.to_s+commit.to_s).assert_post_conditions
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
module Constants
end #Constants
include Constants
module Examples
include Constants
Temporary='~/Desktop/git/'
Source='/media/greg/SD_USB_32G/Repository Backups/'
end #Examples
include Examples
end #Minimal


