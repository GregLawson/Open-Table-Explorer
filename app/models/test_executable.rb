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
require_relative '../../app/models/file_argument.rb'
class TestExecutable < FileArgument # executable / testable ruby unit with executable
  include Virtus.value_object
  values do
    attribute :test_type, Symbol, default: 'unit' # is this a virtus bug? automatic String to Symbol conversion
    attribute :ruby_interpreter, RubyInterpreter, default: RubyInterpreter::Preferred
    #	attribute :test, String, :default => nil # all tests in file
  end # values
  module ClassMethods
    def new_from_path(argument_path,
                      test_type = nil,
                      repository = Repository::This_code_repository)
      argument_path = RepositoryPathname.new_from_path(argument_path) if argument_path.instance_of?(String)
      unit = RailsishRubyUnit.new_from_path(argument_path)
      test_type = FilePattern.find_from_path(argument_path)[:name] if test_type.nil?
      new_executable = TestExecutable.new(argument_path: argument_path,
                                          unit: unit,
                                          test_type: test_type,
                                          repository: repository)
    end # new_from_path
  end # ClassMethods
  extend ClassMethods
  def regression_unit_test_file
    if generatable_unit_file?
      RepositoryPathname.new_from_path(@unit.pathname_pattern?(@test_type)) # unit_test_path
    else
      RepositoryPathname.new_from_path(@argument_path) # nonunit file
    end # if
  end # regression_unit_test_file

  def recursion_message
    if recursion_danger?
      'recursion_danger? since ' + regression_unit_test_file.expand_path.to_s + '==' + File.expand_path($PROGRAM_NAME)
    else
      ''
    end # if
  end # recursion_message

  def recursion_danger?
    regression_unit_test_file.expand_path.to_s == File.expand_path($PROGRAM_NAME)
  end # recursion_danger?

  # test dirty working directory for needed regression test
  # return nil if not in unit since regression testing is then impossible
  def testable?
    if unit_file? # probably can't test if not in a unit
      if recursion_danger?
        false # terminate recursion
      elsif generatable_unit_file? && @test_type == :unit
        true
      elsif regression_unit_test_file.to_s[-3..-1] == '.rb'
        true
      elsif @pattern[:suffix][-8..-1] == '_test.rb'
        true
      elsif @test_type == :unit
        true
      else
        false
      end # if
     end # if
  end # testable?

  def regression_test
    if testable?
      test_run = TestRun.new(TestExecutable.new(argument_path: unit_test_path)).error_score?
    end # if
  end # regression_test

  def log_path?(test, extension = '.log')
    if @unit.nil?
      @log_path = '' # empty file string
    else
      @log_path = 'log/'
      @log_path += @test_type.to_s
      @log_path += '/' + @ruby_interpreter.minor_version
      @log_path += '/' + @ruby_interpreter.patch_version
      @log_path += '/' + @ruby_interpreter.logging.to_s
      if test.nil?
        Pathname.new(@log_path).mkpath
        @log_path += '/' + @unit.model_basename.to_s + extension
      else
        @log_path += '/' + @unit.model_basename.to_s
        Pathname.new(@log_path).mkpath
        @log_path += '/' + test.to_s + extension
      end # if
    end # if
    @log_path
  end # log_path?

  def ruby_test_string(test)
    case @ruby_interpreter.logging
    when :silence then @ruby_test_string = 'ruby -v -W0 '
    when :medium then @ruby_test_string = 'ruby -v -W1 '
    when :verbose then @ruby_test_string = 'ruby -v -W2 '
    else raise Exception.new(logging.to_s + ' is not a valid logging type.')
    end # case
    @ruby_test_string += regression_unit_test_file.to_s
    if test.nil?
      @ruby_test_string
    else
      @ruby_test_string += ' --name ' + test.to_s
    end # if
  end # ruby_test_string

  def all_test_names
    grep_run = ShellCommands.new('grep "^ *def test_" ' + regression_unit_test_file.to_s)
    test_names = grep_run.output.split("\n").map do |line|
      line[11..-1]
    end # map
  end # all_test_names

  def all_library_method_names
    grep_run = ShellCommands.new('grep "^ *def " ' + RepositoryPathname.new_from_path(@unit.pathname_pattern?(:model)).to_s)
    test_names = grep_run.output.split("\n").map do |line|
      line[6..-1]
    end # map
  end # all_library_method_names
  # log_file => String
  # Filename of log file from test run
  module Examples
    # include Constants
    TestTestExecutable = TestExecutable.new_from_path(__FILE__, :unit) # used as Example in TestRun avoiding recursion_danger
    TestSelf = TestExecutable.new(argument_path: $PROGRAM_NAME)
    Not_unit = TestExecutable.new(argument_path: '/dev/null')
    Not_unit_executable = TestExecutable.new(argument_path: 'test/data_sources/unit_maturity/success.rb')
    TestMinimal = TestExecutable.new(argument_path: 'test/unit/minimal2_test.rb')
    Unit_non_executable = TestExecutable.new(argument_path: 'log/unit/2.2/2.2.3p173/silence/test_executable.log')
    Ignored_data_source = TestExecutable.new(argument_path: 'log/unit/2.2/2.2.3p173/silence/CA_540_2014_example-1.jpg')
    Non_test = TestExecutable.new_from_path('app/models/test_executable.rb', :unit)
  end # Examples
end # TestExecutable
