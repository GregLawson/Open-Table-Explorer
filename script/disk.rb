#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2015-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../app/models/script_environment_no_assertions.rb'
require_relative '../app/models/unit.rb' # before command_line
require_relative "../app/models/#{Unit::Executable.model_basename}"
require_relative '../app/models/command_line.rb'
scripting_executable = TestExecutable.new_from_path($PROGRAM_NAME)
require_relative "../app/models/#{scripting_executable.unit.model_basename}.rb"
script_class = RailsishRubyUnit::Executable.model_class?
script = CommandLine.new(executable: $PROGRAM_NAME, unit_class: script_class)
pp ARGV if $VERBOSE
run = script.run do
end # do run
puts Disk.disks
puts Disk.kernels
Disk.grubs.each do |grub|
  puts grub.inspect
end # each
puts 'ret = ' + ret.inspect unless $VERBOSE.nil?
1 # successfully completed
