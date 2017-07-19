###########################################################################
#    Copyright (C) 2012-2017 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../unit/test_environment'
require_relative "../../app/models/rebuild.rb"
class RebuildTest < TestCase
include Rebuild::Examples
Clean_Example=Rebuild.new(Source+'development_old')
  def test_git_path_to_repository
    executing_repo = { name: :'Open-Table-Explorer', dir: Pathname.new(Repository::This_code_repository.path) }
    file = Repository::This_code_repository.path + '.git/'
    dot_git_just_seen = false
    repository = nil # need scope outside of ascend block=
    Pathname.new(file).ascend do |parent|
      if dot_git_just_seen
        dot_git_just_seen = nil # not any more
        assert_equal(Pathname.new('/home/pi/Desktop/src/Open-Table-Explorer'), Pathname.new(parent).expand_path)
        repo_path = Pathname.new(Pathname.new(parent).expand_path.to_s + '/')
        #			assert_equal(repo_path, Pathname.new(parent).expand_path + '/')
        repository = { name: File.basename(parent).to_sym, dir: repo_path }
      elsif File.basename(parent) == '.git'
        dot_git_just_seen = true
      end # if
    end # ascend
    message = 'defined?(dot_git_just_seen) = ' + defined?(dot_git_just_seen) + ' for file ' + file
    assert(defined?(dot_git_just_seen), message)
    assert_instance_of(Hash, repository)
    assert_equal(executing_repo, repository)
  end # git_path_to_repository

#puts "cd_command=#{cd_command.inspect}"
#exists Clean_Example.git_command("branch details").assert_post_conditions
#exists Clean_Example.git_command("branch summary").assert_post_conditions


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
def test_Constants
  path=Source+'development_old'
  assert(File.exists?(path))
  development_old=Rebuild.new(path)
end #Examples
end #Rebuild
