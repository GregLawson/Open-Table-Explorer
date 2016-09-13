#!/usr/bin/ruby
###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../app/models/script_environment_no_assertions.rb'
require_relative '../app/models/unit.rb' # before command_line
require_relative "../app/models/#{RailsishRubyUnit::Executable.model_basename}"
class CommandLine # < Command
  # help for command_line script, overrides default
  def help_banner_string
    ret = 'Usage: ' + ' unit_basename subcommand  options args'
    ret += 'Possible unit names:'
    ret += Unit.all_basenames.join(', ')
    ret += ' subcommands or units:  ' + SUB_COMMANDS.join(', ')
    ret += ' candidate_commands with ' + command_line.number_of_arguments.to_s + ' or variable number of arguments:  '
    command_line.candidate_sub_commands_strings.each do |candidate_commands_string|
      ret += '   ' + candidate_commands_string
    end # each
    ret += 'args may be paths, units, branches, etc.'
    ret += 'options:'
  end # help_string

  def command_line_parser
    command_line = self
    Trollop::Parser.new do
      banner 'Usage: ' + ' unit_basename subcommand  options args'
      #		banner ' subcommands or units:  ' + SUB_COMMANDS.join(', ')
      if command_line.number_of_arguments < 1
        banner 'Possible unit names:'
        banner Unit.all_basenames.join(' ,')
      elsif command_line.number_of_arguments == 1
        banner ' all candidate_commands '
        command_line.candidate_sub_commands_strings.each do |candidate_commands_string|
          banner '   '  + candidate_commands_string
        end # each
      else
        banner ' candidate_commands with ' + command_line.number_of_arguments.to_s + ' or variable number of arguments:  '
        command_line.candidate_sub_commands_strings.each do |candidate_commands_string|
          banner '   '  + candidate_commands_string
        end # each
      end # if
      banner 'args may be paths, units, branches, etc.'
      banner 'options:'
      opt :inspect, 'Inspect ' # + Command.to_s + ' object'
      opt :test, 'Test unit.' # string --name <s>, default nil
      stop_on SUB_COMMANDS
    end
  end # command_line_parser

  def command_line_opts_initialize
    p = command_line_parser
    Trollop.with_standard_exception_handling p do
      o = p.parse @argv
      raise Trollop::HelpNeeded if @argv.empty? # show help screen
      o
    end
  end # command_line_opts
end # CommandLine
require_relative '../app/models/command_line.rb'
puts 'command_line_opts = ' + CommandLine::Script_command_line.command_line_opts.inspect
puts 'command_line_opts.class = ' + CommandLine::Script_command_line.command_line_opts.class.inspect
puts 'command_line_opts[:test] = ' + CommandLine::Script_command_line.command_line_opts[:test].inspect
puts 'command_line_opts[:inspect] = ' + CommandLine::Script_command_line.command_line_opts[:inspect].inspect
puts 'command_line_opts[:inspect_given] = ' + CommandLine::Script_command_line.command_line_opts[:inspect_given].inspect
puts 'CommandLine::Script_command_line = ' + CommandLine::Script_command_line.inspect if $VERBOSE
CommandLine::Script_command_line.run do
  if CommandLine::Script_command_line.command_line_opts[:help]
    puts 'command_line_opts[:help] = ' + CommandLine::Script_command_line.command_line_opts[:help].inspect
    true # done
  elsif CommandLine::Script_command_line.command_line_opts[:test]
    test_run = TestRun.new(test_executable: TestExecutable.new(argument_path: ARGV[1])).error_score?(nil)
    puts test_run.inspect
  else
    sub_command = CommandLine::Script_command_line.sub_command
    sub_command_unit = RailsishRubyUnit.new(model_basename: sub_command.to_sym)
    required_library_file = sub_command_unit.model_pathname?
    if File.exist?(required_library_file)
      require File.expand_path(required_library_file).to_s # require ordering problem
    elsif !Unit.all.include?(sub_command_unit)
      raise "\n\n" + sub_command_unit.model_basename.to_s + ' is not a unit. Please choose one of the following: ' + Unit.all_basenames.join(' ,')
    else
      raise "required_library_file #{required_library_file} does not exist."
      end # if
    puts 'sub_command = ' + sub_command.inspect + sub_command_unit.inspect if $VERBOSE
    sub_command_test_executable = TestExecutable.new_from_path(required_library_file)
		sub_command_commandline = CommandLine.new(test_executable: sub_command_test_executable, argv: ARGV[1..-1])
    sub_command_commandline.run do
      puts 'run in command_line script.' + CommandLine::Script_command_line.command_line_parser.inspect if $VERBOSE
      false # not done
    end # run
    end # if help
end # do run
1 # successfully completed
