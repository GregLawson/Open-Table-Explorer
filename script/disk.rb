#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2015 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# @see http://ruby-doc.org/stdlib-2.0.0/libdoc/optparse/rdoc/OptionParser.html#method-i-make_switch
# require_relative '../app/models/command_line.rb'
# require_relative '../app/models/test_executable.rb'
# scripting_executable = TestExecutable.new_from_path($0)
require_relative '../app/models/disk.rb'
# script_class = Unit::Executing_Unit.model_class?
# script = CommandLine.new($0)
puts Disk.disks
puts Disk.kernels
Disk.grubs.each do |grub|
  puts grub.inspect
end # each
puts 'ret = ' + ret.inspect unless $VERBOSE.nil?
1 # successfully completed
