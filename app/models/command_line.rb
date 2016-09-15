###########################################################################
#    Copyright (C) 2013-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'trollop'
require 'virtus'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/command.rb'
require_relative '../../app/models/test_executable.rb'
require_relative '../../app/models/method_model.rb'
require_relative '../../app/models/command_line_sub_executable.rb'


class CommandLine < CommandLineSubExecutable # < Command
  module DefinitionalConstants # constant parameters of the type (suggest all CAPS)
    Command_line_opts_default = lambda do |commandline, _attribute|
      commandline.command_line_opts_initialize
    end # command_line_opts
    end # DefinitionalConstants
  include DefinitionalConstants
  module DefinitionalClassMethods # compute sub-objects such as default attribute values
    include DefinitionalConstants
  end # DefinitionalClassMethods
  extend DefinitionalClassMethods
  include Virtus.value_object
  values do
    #	attribute :command_line_opts, Hash, :default => lambda {|commandline, attribute| commandline.command_line_opts_initialize}
  end # values

  module ClassMethods # such as alternative new methods
    include DefinitionalConstants
  end # ClassMethods
  extend ClassMethods

  def sub_command
    if command_line_opts[:help]
      :help # default subcommand
    else
      super # get the subcommand
    end # if
  end # sub_command

	
  def candidate_sub_commands_strings
      sub_command_instance_methods.map do |method_model|
        method_model.prototype(ancestor_qualifier: false, argument_delimeter: ' ')
      end # map
  end # candidate_sub_commands_strings

  # default help, override as needed
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
  end # help_banner_string

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
      #		opt :inspect, 'Inspect ' + Command.to_s + ' object'
      opt :test, 'Test unit.' # string --name <s>, default nil
      stop_on SUB_COMMANDS
    end
  end # command_line_parser

  def command_line_opts
    p = command_line_parser
    Trollop.with_standard_exception_handling p do
      o = p.parse @argv
      raise Trollop::HelpNeeded if @argv.empty? # show help screen
      o
    end
  end # command_line_opts
	
  module Constants # constant objects of the type
    include DefinitionalConstants
    # Command = RailsishRubyUnit::Executable.model_basename
    Script_class = RailsishRubyUnit::Executable.model_class?
    Script_command_line = CommandLine.new(test_executable: TestExecutable.new_from_path($PROGRAM_NAME), argv: ARGV)
      # = Script_class.new(TestExecutable.new_from_path($0))
    end # Constants
  include Constants

end # CommandLine
