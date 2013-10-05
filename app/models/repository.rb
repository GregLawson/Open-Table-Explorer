###########################################################################
#    Copyright (C) 2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'grit'  # sudo gem install grit
# rdoc at http://grit.rubyforge.org/
# partial API at less /usr/share/doc/ruby-grit/API.txt
# code in /usr/lib/ruby/vendor_ruby/grit
require_relative 'shell_command.rb'
class Repository <Grit::Repo
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
attr_reader :path, :recent_test, :deserving_branch
def initialize(path)
	@url=path
	@path=path
	source_path=@path
	temporary_path=Temporary+'recover'
  puts '@path='+@path if $VERBOSE
	super(@path)
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
	head.name.to_sym
end #current_branch_name
def deserving_branch?(executable=@related_files.model_test_pathname?)
	@recent_test=shell_command("ruby "+executable)
	@recent_test.puts if $VERBOSE
	if @recent_test.success? then
		@deserving_branch=:passed
	elsif @recent_test.process_status.exitstatus==1 then # 1 error or syntax error
		syntax_test=shell_command("ruby -c "+executable)
		if syntax_test.output=="Syntax OK\n" then
			@deserving_branch=:testing
		else
			@deserving_branch=:edited
		end #if
	else
		@deserving_branch=:testing
	end #if
	@deserving_branch
end #deserving_branch
# This is safe in the sense that a stash saves all files
# and a stash apply restores all tracked files
# safe is meant to mean no files or changes are lost or buried.
def safely_visit_branch(target_branch, &block)
	push_branch=current_branch_name?
	if push_branch!=target_branch then
		git_command("stash save").assert_post_conditions
		git_command('checkout #{target_branch}').assert_post_conditions
		ret=block.call(self)
		git_command('checkout #{push_branch}').assert_post_conditions
		git_command('stash apply').assert_post_conditions
	else
		ret=block.call(self)
	end #if
	ret
end #safely_visit_branch
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
	git_command("add "+tested_files.join(' ')).assert_post_conditions	
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
def assert_deserving_branch(branch_expected, executable)
	deserving_branch=deserving_branch?(executable)
	recent_test=shell_command("ruby "+executable)
	message+="\nrecent_test="+recent_test.inspect
	syntax_test=shell_command("ruby -c "+executable)
	message+="\nsyntax_test="+syntax_test.inspect
	case 
	when :edited then
		assert_equal(1, recent_test.process_status.exitstatus, message)
		assert_not_equal("Syntax OK\n", syntax_test.output, message)
	when :testing then
		assert_operator(1, :<=, recent_test.process_status.exitstatus, message)
		assert_equal("Syntax OK\n", syntax_test.output, message)
	when :passed then
		assert_equal(0, recent_test.process_status.exitstatus, message)
		assert_equal("Syntax OK\n", syntax_test.output, message)
	end #case
	assert_equal(deserving_branch, branch_expected, message)
end #deserving_branch
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


