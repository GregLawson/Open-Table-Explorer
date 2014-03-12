###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative "../../app/models/rebuild.rb"
class RebuildTest < TestCase
include DefaultTests
include Rebuild::Examples
#puts "cd_command=#{cd_command.inspect}"
def test_inspect
	puts Clean_Example.target_repository.git_command('log --format="%h %aD"').output.split("\n")[0]
end # inspect
def test_latest_commit
	latest_log=@latest_commit=Clean_Example.target_repository.git_command('log --format="%H %aD" --max-count=1').output.split("\n")[0]
	
	commit_SHA1=latest_log[0..Full_SHA_digits-1]
	commit_timestamp=latest_log[Full_SHA_digits..-1]
	assert_equal({commit_SHA1: commit_SHA1, commit_timestamp: commit_timestamp}, Clean_Example.latest_commit)
end # latest_commit
def test_corruption_fsck
#	Toy_repository.git_command("fsck").assert_post_conditions
end #corruption
def test_corruption_rebase
#	Toy_repository.git_command("rebase").assert_post_conditions
end #corruption
def test_corruption_gc
	Toy_repository.git_command("gc").assert_post_conditions
end #corruption
#exists Toy_repository.git_command("branch details").assert_post_conditions
#exists Toy_repository.git_command("branch summary").assert_post_conditions
def test_standardize_position
	Toy_repository.git_command("rebase --abort").puts
	Toy_repository.git_command("merge --abort").puts
#	Toy_repository.git_command("stash save").assert_post_conditions
	Toy_repository.git_command("checkout master").puts
#	Toy_repository.standardize_position!
end #standardize_position
def test_fetch_repository
	repository_file=From_repository
	Clean_Example.assert_pre_conditions
	run=Clean_Example.target_repository.git_command("fetch file://"+Shellwords.escape(repository_file))
	run.assert_post_conditions unless run.success?
	Clean_Example.fetch_repository(repository_file)
#	Clean_Example.fetch_repository(Source+"clone-reconstruct-newer")
	Clean_Example.assert_post_conditions
end #fetch_repository

def test_add_commits
	from_repository=From_repository
	last_commit_to_add='master'
	branch='master'
	Clean_Example.git_command("fetch file://"+from_repository+" "+branch)
#	Clean_Example.git_command("checkout  #{branch}").assert_post_conditions
#	Clean_Example.git_command("merge #{History_options} "+" -m "+name.to_s+commit.to_s).assert_post_conditions
#add_commits("postgres", :postgres, Temporary+"details")
#add_commits("activeRecord", :activeRecord, Temporary+"details")
#add_commits("rails2", :rails2, Temporary+"details")
#add_commits("rails3", :rails3, Temporary+"details")
#add_commits("", :default, Source+"details")
#add_commits("taxesFreeeze", :taxesFreeeze, Source+"copy-master")
#add_commits("", :taxesStopped, Source+"copy-master")
#add_commits("development", :development, Source+"copy-master")
#add_commits("compiles", :compiles, Source+"copy-master")
#add_commits("master", :master, Source+"copy-master")
#add_commits("usb", :usb, Source+"clone-reconstruct-newer ")


#ShellCommands.new("rsync -a #{Temporary}recover /media/greg/B91D-59BB/recover").assert_post_conditions
end #add_commits
def test_Constants
  path=Source+'test_recover'
  assert_pathname_exists(path)
#  development_old=Rebuild.new(path)
end #Examples
end #Rebuild
