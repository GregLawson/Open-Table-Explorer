###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative "../../app/models/repository.rb"
class Rebuild < Repository
module Constants
Temporary='/tmp/recover/'
Full_SHA_digits=40
end #Constants
module ClassMethods
end #ClassMethods
extend ClassMethods
require_relative "shell_command.rb"
#subshell (cd_command=ShellCommands.new("cd #{Temporary}recover")).assert_post_conditions
#puts "cd_command=#{cd_command.inspect}"
attr_reader :target_repository, :import_repository
def initialize(target_repository)
	@target_repository=target_repository
end # initialize
def inspect
end # inspect
def latest_commit
	latest_log=@latest_commit=@target_repository.git_command('log --format="%H %aD" --max-count=1').output.split("\n")[0]
	commit_SHA1=latest_log[0..Full_SHA_digits-1]
	commit_timestamp=latest_log[Full_SHA_digits..-1]
	{commit_SHA1: commit_SHA1, commit_timestamp: commit_timestamp}
end # latest_commit
def import
	if File.exists?(@path) then
		command_string='rsync '+Shellwords.escape(source_path)+' '+Shellwords.escape(temporary_path)
		ShellCommands.new(command_string).assert_post_conditions #uncorrupted old backup to start
	else
		command_string='cp -a '+Shellwords.escape(source_path)+' '+Shellwords.escape(temporary_path)
		ShellCommands.new(command_string).assert_post_conditions #uncorrupted old backup to start
	end #if
end # import
def fetch_repository(repository_file)
	@import_repository=Repository.new(repository_file)
	@run=@target_repository.git_command("fetch file://"+Shellwords.escape(repository_file))
	if @run.success?
		@target_repository.git_command("merge "+'FETCH_HEAD'.to_s).assert_post_conditions
	else
		@run.assert_post_conditions
	end # if
#	@target_repository.git_command("fetch file://"+repository_file+" "+name)
end #fetch_repository
def initialize_branch(name, commit, repository_file)
	Clean_Example.git_command("fetch file://"+repository+" "+name)
	Clean_Example.git_command("symbolic-link #{name.to_s} "+commit.to_s).assert_post_conditions
end #initialize_branch

def add_commits(from_repository, last_commit_to_add, branch, history_options='--squash -Xthiers ')
	@target_repository.git_command("fetch file://"+repository+" "+name)
	@target_repository.git_command("checkout  #{branch}").assert_post_conditions
	@target_repository.git_command("merge #{history_options} "+" -m "+name.to_s+commit.to_s).assert_post_conditions
end #add_commits
module Assertions
include Test::Unit::Assertions
module ClassMethods
include Test::Unit::Assertions
def assert_post_conditions
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions
	assert_pathname_exists(@target_repository.path)
	assert_pathname_exists(@target_repository.path+'.git/')
	assert_pathname_exists(@target_repository.path+'.git/branches/')
	assert_pathname_exists(@target_repository.path+'.git/config')
	assert_pathname_exists(@target_repository.path+'.git/description')
	assert_pathname_exists(@target_repository.path+'.git/HEAD')
	assert_pathname_exists(@target_repository.path+'.git/hooks/')
	assert_pathname_exists(@target_repository.path+'.git/info/')
	assert_pathname_exists(@target_repository.path+'.git/refs/')
	assert_pathname_exists(@target_repository.path+'.git/objects/')
#	fail 'assert_pre_conditions called'
end #assert_pre_conditions
def assert_post_conditions
#	assert_pathname_exists(@target_repository.path+'.git/logs/')
#	assert_pathname_exists(@target_repository.path+'.git/logs/refs/')
end #assert_post_conditions
end #Assertions
include Assertions
#TestWorkFlow.assert_pre_conditions
include Constants
module Examples
include Constants
Source='/media/sdd1/Repository Backups/'
Toy_repository=Repository.replace_or_create(Temporary+'toy_repository')
Real_repository=Repository.create_if_missing(Temporary+'real_repository')
Clean_Example=Rebuild.new(Toy_repository)
From_repository=Source+"copy-master"
History_options='--squash -Xthiers '

end #Examples
#include Examples
end #Rebuild


