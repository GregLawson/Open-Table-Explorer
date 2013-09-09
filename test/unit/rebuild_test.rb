###########################################################################
#    Copyright (C) 2012-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative "../../app/models/rebuild.rb"
class RebuildTest < TestCase
include Rebuild::Examples
#puts "cd_command=#{cd_command.inspect}"
def test_corruption_fsck
#	Development_old.git_command("fsck").assert_post_conditions
end #corruption
def test_corruption_rebase
#	Development_old.git_command("rebase").assert_post_conditions
end #corruption
def test_corruption_gc
#	Development_old.git_command("gc").assert_post_conditions
end #corruption
#exists Development_old.git_command("branch details").assert_post_conditions
#exists Development_old.git_command("branch summary").assert_post_conditions


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
