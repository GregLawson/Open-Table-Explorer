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
def test_git_path_to_repository
	executing_repo = {name: :'Open-Table-Explorer', dir: Pathname.new(Repository::This_code_repository.path)}
	file = Repository::This_code_repository.path + '.git/'
	dot_git_just_seen = false
	repository = nil # need scope outside of ascend block=
	Pathname.new(file).ascend do |parent|
		if dot_git_just_seen then
			dot_git_just_seen = nil # not any more
			assert_equal(Pathname.new('/home/pi/Desktop/src/Open-Table-Explorer'), Pathname.new(parent).expand_path)
			repo_path = Pathname.new(Pathname.new(parent).expand_path.to_s + '/')
#			assert_equal(repo_path, Pathname.new(parent).expand_path + '/')
			repository = {name: File.basename(parent).to_sym, dir: repo_path}
		elsif File.basename(parent) == '.git'
			dot_git_just_seen = true
		end # if
	end # ascend
	message= 'defined?(dot_git_just_seen) = '+ defined?(dot_git_just_seen) + ' for file ' + file
	assert(defined?(dot_git_just_seen), message)
	assert_instance_of(Hash, repository)
	assert_equal(executing_repo, repository)
end # git_path_to_repository
def test_get_name
	assert_equal('Open-Table-Explorer', Repository::This_code_repository.get_name)
end # get_name
def test_named_repository_directories
	directories_of_repositories = ['../']
	repository_glob = Repository_glob
	repository_directories= directories_of_repositories.map do |directory|
		assert_pathname_exists(directory)
		files=Dir[directory + repository_glob]
		assert_not_empty(files, 'Looking for directory + Repository_glob=' + directory + Repository_glob)
		repositories=files.map do |path|
			assert_pathname_exists(path)
			Repository.git_path_to_repository(path)
		end # map
		assert_not_empty(files)
		repositories
	end.flatten # map
	assert_not_empty(repository_directories)
	executing_repo = Repository::This_code_repository
	message = 'executing_repo='+executing_repo.inspect
	assert_equal(repository_directories[1], executing_repo, message)
	assert_include(repository_directories, executing_repo, message)
	repository_directories = Rebuild.named_repository_directories(Directories_of_repositories, Repository_glob)
	assert_include(repository_directories, executing_repo)
end # named_repository_directories
#
#
#
#
#
def test_clone
	source_repository_path = Small_repository.path
	command_string='git clone '+Shellwords.escape(source_repository_path)
end # clone
def test_fetch
	source_repository_path = Small_repository.path
end # fetch
def test_copy
	source_repository_path = Small_repository.path
#	command_string='cp -a '+Shellwords.escape(source_path)+' '+Shellwords.escape(temporary_path)
#	ShellCommands.new(command_string).assert_post_conditions #uncorrupted old backup to start
end # copy
def test_rsync
	source_repository_path = Small_repository.path
end # rsync
#puts "cd_command=#{cd_command.inspect}"
def test_inspect
	puts Clean_Example.source_repository.git_command('log --format="%h %aD"').output.split("\n")[0]
end # inspect
def test_latest_commit
	latest_log=@latest_commit=Clean_Example.source_repository.git_command('log --format="%H %aD" --max-count=1').output.split("\n")[0]
	
	commit_SHA1=latest_log[0..Full_SHA_digits-1]
	commit_timestamp=latest_log[Full_SHA_digits..-1]
	assert_equal({commit_SHA1: commit_SHA1, commit_timestamp: commit_timestamp}, Clean_Example.latest_commit)
end # latest_commit
def test_graft
# cd /tmp/
#	git_command('git clone good-host:/path/to/good-repo')
#	git_command('cd /home/user/broken-repo')
#	Small_repository.shell_command('echo '+graft_replacement_repository+'/.git/objects/ > '+@path+'.git/objects/info/alternates')
#	Small_repository.git_command('repack -a -d')
#	shell_command('rm -rf /tmp/good-repo')
end # graft
def test_destructive_status!
#	Small_repository.git_command("fsck").assert_post_conditions
#	Small_repository.git_command("rebase").assert_post_conditions
	Small_repository.git_command("gc").assert_post_conditions
	Real_repository.git_command("gc").assert_post_conditions
#	Small_repository.destructive_status!
#	Real_repository.destructive_status!
end #destructive_status!
def test_repack
end # repack
def test_fetch_repository
	repository_file=From_repository
	Clean_Example.assert_pre_conditions
	run=Clean_Example.source_repository.git_command("fetch file://"+Shellwords.escape(repository_file))
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
#exists Small_repository.git_command("branch details").assert_post_conditions
#exists Small_repository.git_command("branch summary").assert_post_conditions
end #add_commits
def test_Examples
  path=Source+'test_recover'
  assert_pathname_exists(path)
#  development_old=Rebuild.new(path)
end #Examples
end #Rebuild
