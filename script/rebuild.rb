###########################################################################
#    Copyright (C) 2013 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'optparse'
require 'ostruct'
require 'pp'
require_relative '../app/models/rebuild.rb'
Temporary = '~/Desktop/git/'.freeze
Source = '/media/greg/SD_USB_32G/Repository Backups/'.freeze
ShellCommands.new("copy -a #{Source}development_old #{Temporary}recover").assert_post_conditions # uncorrupted old backup to start
# subshell (cd_command=ShellCommands.new("cd #{Temporary}recover")).assert_post_conditions
# puts "cd_command=#{cd_command.inspect}"
# exists ShellCommands.new("git branch details").assert_post_conditions
ShellCommands.new('git reset 8db16b5cfaa0adacfd157c8ffba727c26117179d').assert_post_conditions
# exists ShellCommands.new("git branch summary").assert_post_conditions

# add_commits("postgres", :postgres, Temporary+"details")
# add_commits("activeRecord", :activeRecord, Temporary+"details")
# add_commits("rails2", :rails2, Temporary+"details")
# add_commits("rails3", :rails3, Temporary+"details")
# add_commits("", :default, Source+"details")
# add_commits("taxesFreeeze", :taxesFreeeze, Source+"copy-master")
# add_commits("", :taxesStopped, Source+"copy-master")
# add_commits("development", :development, Source+"copy-master")
# add_commits("compiles", :compiles, Source+"copy-master")
# add_commits("master", :master, Source+"copy-master")
# add_commits("usb", :usb, Source+"clone-reconstruct-newer ")

# ShellCommands.new("rsync -a #{Temporary}recover /media/greg/B91D-59BB/recover").assert_post_conditions
