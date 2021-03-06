#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2013-2014 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# @see http://ruby-doc.org/stdlib-2.0.0/libdoc/optparse/rdoc/OptionParser.html#method-i-make_switch
require 'pp'
require_relative '../app/models/work_flow.rb'
require_relative '../app/models/command_line.rb'
require_relative '../app/models/unit.rb'
scripting_workflow = WorkFlow.new($PROGRAM_NAME)
# good enough for edited; no syntax error
scripting_workflow.script_deserves_commit!(:edited)
unit_files = Unit.new_from_path?($PROGRAM_NAME)
require_relative "../app/models/#{unit_files.model_basename}"
commands = []
script = CommandLineScript.new($PROGRAM_NAME)
script.add_option('Rebase smoke test.', :noop)
script.add_option('Rebase auto-squash test.', :squash)
script.add_option('Rebase flip-first test.', :flip_first)
script.parse_options

pp commands
pp ARGV
case ARGV.size # paths after switch removal?
when 0 then # scite testing defaults command and file
  puts script.banner
  this_file = File.expand_path(__FILE__)
  argv = [this_file] # incestuous default test case for scite
  commands = [:noop]
else
  argv = ARGV
end # case
commands.each do |c|
  case c.to_sym
  when :all then

  else argv.each do |f|
    puts unit_files.inspect.to_s
    unit = unit_files.model_class?.new(f)
    case c.to_sym
    when :noop then
    when :test then unit.test
    else
      if unit.respond_to?(c.to_sym)
        unit.send(c.to_sym, *argv)
      else
        puts "#{c.to_sym} is not a method in #{unit_files.inspect}"
      end # if
    end # case
    scripting_workflow.script_deserves_commit!(:passed)
  end # each
  end # case
end # each
1 # successfully completed
