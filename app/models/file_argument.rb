###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require_relative '../../app/models/no_db.rb'
require 'virtus'
# require 'fileutils'
require_relative '../../app/models/repository.rb'
require_relative '../../app/models/ruby_interpreter.rb'
# require_relative '../../app/models/shell_command.rb'
# require_relative '../../app/models/branch.rb'
require_relative '../../app/models/repository_pathname.rb'
class RepositoryAssociation < Virtus::Attribute
  def coerce(path)
    path.is_a?(::RepositoryPathname) ? path : RepositoryPathname.new_from_path(path)
  end # coerce
end # RepositoryAssociation

class FileArgument
  include Virtus.model
  attribute :argument_path, RepositoryAssociation
  attribute :unit, RailsishRubyUnit, default: ->(argument, _attribute) { RailsishRubyUnit.new_from_path(argument.argument_path) }
  attribute :pattern, Symbol, default: ->(argument, _attribute) { FilePattern.find_from_path(argument.argument_path) }
  attribute :repository, Repository, default: Repository::This_code_repository
  module Examples
    TestSelf = FileArgument.new(argument_path: $PROGRAM_NAME)
    Not_unit = FileArgument.new(argument_path: '/dev/null')
    Not_unit_executable = FileArgument.new(argument_path: 'test/data_sources/unit_maturity/success.rb')
    TestMinimal = FileArgument.new(argument_path: 'test/unit/minimal2_test.rb')
    Unit_non_executable = FileArgument.new(argument_path: 'log/unit/2.2/2.2.3p173/silence/test_executable.log')
    Ignored_data_source = FileArgument.new(argument_path: 'log/unit/2.2/2.2.3p173/silence/CA_540_2014_example-1.jpg')
  end # Examples

  def lint_output
    if unit_file?
      input_files = @unit.edit_files
      output_files = [@argument_path.lint_out_file]
      file_ipo = FileIPO.new(input_files: input_files, command_string: @argument_path.lint_command_string, output_files: output_files)
      if file_ipo.input_updated?
        message = file_ipo.inspect
        message += "\n"
        message += file_ipo.explain_updated
        puts message if $VERBOSE
        run = file_ipo.run
        #				@errors += file_ipo.errors
        IO.write(@argument_path.lint_out_file.to_s, run.cached_run.output)
        run.cached_run.output
      # tested        raise 'unexpected lint run.'
      else
        IO.read(@argument_path.lint_out_file.to_s)
        end # if
      run.cached_run.output
    else
      @argument_path.lint_output
      # tested      raise 'unexpected lint run.'
    end # if
  end # lint_output

  def unit_file_type
    if pattern.nil?
      :non_unit
    else
      pattern[:name]
   end # if
  end # unit_file_type

  # argument path is in a unit and is a generatable file.
  def unit_file?
    if unit_file_type == :non_unit
      false
    elsif @unit.nil? || @unit.project_root_dir.nil? # probably can't test if not in a unit
      false
    else
      true
    end # if
  end # unit_file?

  def generatable_unit_file?
    if unit_file_type == :non_unit
      false
    elsif @unit.nil? || @unit.project_root_dir.nil? # probably can't test if not in a unit
      false
    elsif @pattern[:generate]
      true
    else
      false
    end # if
  end # generatable_unit_file?

  def lint_unit
    if unit_file?
      @unit.edit_files.each do |p|
        file = FileArgument.new(argument_path: p)
        if file.generatable_unit_file?
          file.argument_path.lint_output
          # tested          raise 'unexpected lint run.'
        end # if
      end # each
    else
      argument_path.lint_output
      raise 'unexpected lint run.'
    end # if
  end # lint_unit
end # FileArgument
