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
class RepositoryPathname < Pathname
  Lint_convention_priorities = ['Metrics/MethodLength', 'Metrics/ClassLength', 'Metrics/LineLength', 'Style/MethodName', 'Metrics/AbcSize', 'Style/IfInsideElse'].freeze
  Lint_warning_priorities = ['Lint/UselessComparison', 'Lint/UselessAssignment'].freeze
  module ClassMethods
    def new_from_path(pathname, repository = Repository::This_code_repository)
      pathname = Pathname.new(pathname.to_s).expand_path
      relative_pathname = pathname.relative_path_from(Pathname.new(repository.path))
      RepositoryPathname.new(relative_pathname: relative_pathname, repository: repository)
    end # new_from_path
  end # ClassMethods
  extend ClassMethods
  include Virtus.value_object
  values do
    attribute :relative_pathname, Pathname # simplify inspect, comparisons, and sorts?
    attribute :repository, Repository, default: Repository::This_code_repository
    attribute :path, String, default: ->(pathname, _attribute) { pathname.to_s }
  end # values
  def <=>(rhs)
    repository_compare = @repository <=> rhs.repository
    if repository_compare == 0
      @relative_pathname.to_s <=> rhs.relative_pathname.to_s
    else
      repository_compare
    end # if
  end # compare

  def inspect
    if @repository == Repository::This_code_repository
      @relative_pathname.to_s
    elsif @relative_pathname.nil?
      'nil pathname'
    else
      @relative_pathname.to_s + ' in ' + @repository.path.to_s
    end # if
  end # inspect

  def expand_path
    Pathname.new(@repository.path.to_s + @relative_pathname.to_s)
  end # expand_path

  def to_s
    Pathname.new(@repository.path.to_s + @relative_pathname.to_s).cleanpath.to_s
  end # to_s
  module Examples
    TestSelf = RepositoryPathname.new_from_path($PROGRAM_NAME)
    Not_unit = RepositoryPathname.new_from_path('/dev/null')
    Not_unit_executable = RepositoryPathname.new(relative_pathname: 'test/data_sources/test_maturity/success.rb')
    TestMinimal = RepositoryPathname.new(relative_pathname: 'test/unit/minimal2_test.rb')
    Unit_non_executable = RepositoryPathname.new(relative_pathname: 'log/unit/2.2/2.2.3p173/silence/minimal2.log')
    Ignored_data_source = RepositoryPathname.new(relative_pathname: 'log/unit/2.2/2.2.3p173/silence/CA_540_2014_example-1.jpg')
  end # Examples

  def lint_command_string(logging = :silence)
    'rubocop --auto-correct --display-style-guide --format json ' +
      #		' -extra-details ' +
      case logging
      when :silence then ''
      when :medium then ''
      when :verbose then ''
      else raise Exception.new(logging.to_s + ' is not a valid logging type.')
     end + ' ' + @relative_pathname.to_s
  end # lint_command_string

  def lint_out_file
    log_path = 'log/'
    log_path += 'lint'
    log_path += '/' + @relative_pathname.to_s + '.json'
    log_path = Pathname.new(log_path)
    log_path.dirname.mkpath
    log_path
  end # lint_out_file

  def lint_output
    input_paths = [to_s]
    output_paths = [lint_out_file]
    file_ipo = FileIPO.new(input_paths: input_paths, command_string: lint_command_string, output_paths: output_paths)
    if file_ipo.input_updated?
      message = file_ipo.inspect
      message += "\n"
      message += file_ipo.explain_updated
      puts message if $VERBOSE
      run = file_ipo.run
      #				@errors += file_ipo.errors
      IO.write(lint_out_file.to_s, run.cached_run.output.gsub('{"s', "\n" + '{"s'))
      run.cached_run.output
    # tested      raise 'unexpected lint run.'
    else
      IO.read(lint_out_file.to_s)
    end # if
  end # lint_output

  def lint_json
    JSON[lint_output]
  end # lint_json

  def lint_warnings
    lint_json['files'][0]['offenses'].select { |o| o['severity'] == 'warning' }
  end # lint_warnings

  def lint_unconventional
    lint_json['files'][0]['offenses'].select { |o| o['severity'] == 'convention' }.sort do |x, y|
      if RepositoryPathname::Lint_convention_priorities.include?(x['cop_name'])
        if RepositoryPathname::Lint_convention_priorities.include?(y['cop_name'])
          RepositoryPathname::Lint_convention_priorities.index(x['cop_name']) <=> RepositoryPathname::Lint_convention_priorities.index(y['cop_name'])
        else
          +1
        end # if
      else
        if RepositoryPathname::Lint_convention_priorities.include?(y['cop_name'])
          -1
        else
          x['cop_name'] > y['cop_name'] # if all else fails, use alphabetical order
        end # if
      end # if
    end # sort
  end # lint_unconventional

  def lint_top_unconventional
    lint_unconventional[0]
  end # lint_top_unconventional
end # RepositoryPathname

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
