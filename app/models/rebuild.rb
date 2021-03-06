###########################################################################
#    Copyright (C) 2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/repository.rb'
class Repository
  module ClassMethods
    def git_path_to_repository(file)
      dot_git_just_seen = false
      repository = nil # need scope outside of ascend block=
      Pathname.new(file).ascend do |parent|
        if dot_git_just_seen
          dot_git_just_seen = nil # not any more
          repo_path = Pathname.new(Pathname.new(parent).expand_path.to_s + '/')
          repository = Repository.new(Pathname.new(Pathname.new(parent).expand_path.to_s + '/'))
        elsif File.basename(parent) == '.git'
          dot_git_just_seen = true
        end # if
      end # ascend
      repository
    end # git_path_to_repository
  end # ClassMethods
  extend ClassMethods
  def initialize(path)
    if path.to_s[-1, 1] != '/'
      path += '/'
     end # if
    @url = path
    @path = path.to_s
    puts '@path=' + @path if $VERBOSE
    @grit_repo = Grit::Repo.new(@path)
   end # initialize

  def inspect
    @path.inspect
  end # inspect

  # names are not unique, directories make them unique
  def get_name
    File.basename(@path)
  end # get_name

  def <=>(other)
    path.to_s <=> other.path.to_s
  end # <=>

  def ==(other)
    path.== other.path.to_s
  end # ==
	
  module Constants
    Directories_of_repositories = ['/media/*/Repository Backups/',
                                   '/media/*/*/Repository Backups/', '/tmp/rebuild', '../'].freeze
  end # Constants
end # Repository

class Rebuild < Repository
  module Constants
    Full_SHA_digits = 40
  end # Constants
  module ClassMethods
    def named_repository_directories(directories_of_repositories, repository_glob)
      repository_directories = directories_of_repositories.map do |directory|
        files = Dir[directory + repository_glob]
        repositories = files.map do |path|
          Repository.git_path_to_repository(path)
        end # map
        repositories
      end.flatten # map
    end # named_repository_directories

    # The following class methods produce a Rebuild object with a copy
    # of a repository. The copy can be made in different ways:
    #	copy - brute force directory copy (corruption untouched)
    #	clone - copy of valid repository (copies object and pack corruption)
    #	fetch - copy of valid repository (fails if object or pack corruption)
    def clone(_name, source_repository_path = nil)
      command_string = 'git clone ' + Shellwords.escape(source_repository_path)
      ShellCommands.new(command_string).assert_post_conditions # uncorrupted old backup to start
    end # clone

    def fetch(_source_repository_path)
      ShellCommands.new(command_string).assert_post_conditions # uncorrupted old backup to start
    end # fetch

    def copy(_source_repository_path)
      command_string = 'cp -a ' + Shellwords.escape(source_repository) + ' ' + Shellwords.escape(temporary_path)
      ShellCommands.new(command_string).assert_post_conditions # uncorrupted old backup to start
    end # copy

    def rsync(source_repository_path)
      if File.exist?(@path)
        command_string = 'rsync ' + Shellwords.escape(source_repository_path) + ' ' + Shellwords.escape(temporary_path)
        ShellCommands.new(command_string).assert_post_conditions # uncorrupted old backup to start
      else
        command_string = 'cp -a ' + Shellwords.escape(source_repository_path) + ' ' + Shellwords.escape(temporary_path)
        ShellCommands.new(command_string).assert_post_conditions # uncorrupted old backup to start
      end # if
    end # rsync
  end # ClassMethods
  extend ClassMethods
  require_relative 'shell_command.rb'
  # subshell (cd_command=ShellCommands.new("cd #{Temporary}recover")).assert_post_conditions
  # puts "cd_command=#{cd_command.inspect}"
  attr_reader :source_repository, :import_repository
  def initialize(source_repository)
    if source_repository.instance_of?(Repository)
      @source_repository = source_repository
    elsif source_repository.instance_of?(String)

      @source_repository = Repository.new(source_repository)
    end # if
  end # initialize

  def inspect
  end # inspect

  def latest_commit
    latest_log = @latest_commit = @source_repository.git_command('log --format="%H %aD" --max-count=1').output.split("\n")[0]
    commit_SHA1 = latest_log[0..Full_SHA_digits - 1]
    commit_timestamp = latest_log[Full_SHA_digits..-1]
    { commit_SHA1: commit_SHA1, commit_timestamp: commit_timestamp }
  end # latest_commit

  def graft(graft_replacement_repository)
    shell_command('echo ' + graft_replacement_repository + '/.git/objects/ > ' + @path + '.git/objects/info/alternates')
    git_command('repack -a -d')
  end # graft

  def destructive_status!
    #	@gc_command = git_command("fsck").assert_post_conditions
    #	@gc_command = git_command("rebase").assert_post_conditions
    @gc_command = git_command('gc')
  end # destructive_status!

  def repack
    ShellCommands.new('mv .git/objects/pack/* /tmp/rebuild/corrupt_packs/')
    ShellCommands.new('for i in /tmp/rebuild/corrupt_packs/*.pack; do;git unpack-objects -r < $i;done')
    ShellCommands.new('rm /tmp/rebuild/corrupt_packs/*')
  end # repack

  def fetch_repository(repository_file)
    @import_repository = Repository.new(repository_file)
    @run = @source_repository.git_command('fetch file://' + Shellwords.escape(repository_file))
    if @run.success?
      @source_repository.git_command('merge ' + 'FETCH_HEAD'.to_s).assert_post_conditions
    else
      @run.assert_post_conditions
    end # if
    #	@source_repository.git_command("fetch file://"+repository_file+" "+name)
  end # fetch_repository

  def initialize_branch(name, commit, _repository_file)
    Clean_Example.git_command('fetch file://' + repository + ' ' + name)
    Clean_Example.git_command("symbolic-link #{name} " + commit.to_s).assert_post_conditions
  end # initialize_branch

  def add_commits(_from_repository, _last_commit_to_add, branch, history_options = '--squash -Xthiers ')
    @source_repository.git_command('fetch file://' + repository + ' ' + name)
    @source_repository.git_command("checkout  #{branch}").assert_post_conditions
    @source_repository.git_command("merge #{history_options} " + ' -m ' + name.to_s + commit.to_s).assert_post_conditions
  end # add_commits
  # require_relative '../../app/models/assertions.rb'
  module Assertions
    module ClassMethods
      def assert_pre_conditions
#!        assert_includes(AssertionsModule.instance_methods, :quieter)
 #!       quieter do
#!        end # quieter
      end # assert_post_conditions

      def assert_post_conditions
      end # assert_post_conditions
    end # ClassMethods
    def assert_pre_conditions
      assert_pathname_exists(@source_repository.path)
      assert_pathname_exists(@source_repository.path + '.git/')
      assert_pathname_exists(@source_repository.path + '.git/branches/')
      assert_pathname_exists(@source_repository.path + '.git/config')
      assert_pathname_exists(@source_repository.path + '.git/description')
      assert_pathname_exists(@source_repository.path + '.git/HEAD')
      assert_pathname_exists(@source_repository.path + '.git/hooks/')
      assert_pathname_exists(@source_repository.path + '.git/info/')
      assert_pathname_exists(@source_repository.path + '.git/refs/')
      assert_pathname_exists(@source_repository.path + '.git/objects/')
      #	fail 'assert_pre_conditions called'
    end # assert_pre_conditions

    def assert_post_conditions
      #	assert_pathname_exists(@source_repository.path+'.git/logs/')
      #	assert_pathname_exists(@source_repository.path+'.git/logs/refs/')
    end # assert_post_conditions
  end # Assertions
  include Assertions
  extend Assertions::ClassMethods
  Rebuild.assert_pre_conditions
  # TestWorkFlow.assert_pre_conditions
  include Constants
  # include Examples
end # Rebuild
