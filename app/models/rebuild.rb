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
require "shell_command.rb"
#subshell (cd_command=ShellCommands.new("cd #{Temporary}recover")).assert_post_conditions
#puts "cd_command=#{cd_command.inspect}"
def fetch_commits(name, commit, repository_file)
	ShellCommands.new("git fetch file://"+repository+" "+name)
end #fetch_commits
def initialize_branch(name, commit, repository_file)
	ShellCommands.new("git fetch file://"+repository+" "+name)
	ShellCommands.new("git symbolic-link #{name.to_s} "+commit.to_s).assert_post_conditions
end #initialize_branch
#exists ShellCommands.new("git branch details").assert_post_conditions
ShellCommands.new("git reset 8db16b5cfaa0adacfd157c8ffba727c26117179d").assert_post_conditions
#exists ShellCommands.new("git branch summary").assert_post_conditions

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
end #Examples
include Examples
end #Minimal


