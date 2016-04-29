###########################################################################
#    Copyright (C) 2011-2016 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative '../../app/models/no_db.rb'
require 'virtus'
#require 'fileutils'
require_relative '../../app/models/repository.rb'
require_relative '../../app/models/ruby_interpreter.rb'
#require_relative '../../app/models/shell_command.rb'
#require_relative '../../app/models/branch.rb'
class RepositoryPathname < Pathname
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
	attribute :repository, Repository, :default => Repository::This_code_repository
	attribute :path, String, :default => 	lambda { |pathname, attribute| pathname.to_s }

end # values
def <=>(rhs)
	repository_compare = @repository <=> rhs.repository
	if repository_compare == 0 then
		@relative_pathname.to_s <=> rhs.relative_pathname.to_s
	else
		repository_compare
	end # if
end # compare
def inspect
	if @repository == Repository::This_code_repository then
		@relative_pathname.to_s
	elsif @relative_pathname.nil? then
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
Not_unit_executable = RepositoryPathname.new(relative_pathname: 'test/data_sources/unit_maturity/success.rb')
TestMinimal  = RepositoryPathname.new(relative_pathname: 'test/unit/minimal2_test.rb')
Unit_non_executable = RepositoryPathname.new(relative_pathname: 'log/unit/2.2/2.2.3p173/silence/test_executable.log')
Ignored_data_source =  RepositoryPathname.new(relative_pathname: 'log/unit/2.2/2.2.3p173/silence/CA_540_2014_example-1.jpg')
end # Examples
end # RepositoryPathname

class RepositoryAssociation < Virtus::Attribute
  def coerce(path)
    path.is_a?(::RepositoryPathname) ? path : RepositoryPathname.new_from_path(path)
  end # coerce
end # RepositoryAssociation

class FileArgument
include Virtus.model
	attribute :argument_path, RepositoryAssociation
	attribute :unit, Unit, :default => 	lambda { |argument, attribute| Unit.new_from_path(argument.argument_path) }
	attribute :pattern, Symbol, :default => 	lambda { |argument, attribute| FilePattern.find_from_path(argument.argument_path) }
	attribute :repository, Repository, :default => Repository::This_code_repository
module Examples
TestSelf = FileArgument.new(argument_path: $PROGRAM_NAME)
Not_unit = FileArgument.new(argument_path: '/dev/null')
Not_unit_executable = FileArgument.new(argument_path: 'test/data_sources/unit_maturity/success.rb')
TestMinimal  = FileArgument.new(argument_path: 'test/unit/minimal2_test.rb')
Unit_non_executable = FileArgument.new(argument_path: 'log/unit/2.2/2.2.3p173/silence/test_executable.log')
Ignored_data_source =  FileArgument.new(argument_path: 'log/unit/2.2/2.2.3p173/silence/CA_540_2014_example-1.jpg')
end # Examples
def unit_file_type
	 if pattern.nil? then
		:non_unit
	else
		pattern[:name]
	end #if
end # unit_file_type
# argument path is in a unit andis a generatable file.
def unit_file?
		if unit_file_type == :non_unit then
			false
		elsif @unit.nil? || @unit.project_root_dir.nil? then # probably can't test if not in a unit
			false
		else
			true
		end # if
end # unit_file?
def generatable_unit_file?
		if unit_file_type == :non_unit then
			false
		elsif @unit.nil? || @unit.project_root_dir.nil? then # probably can't test if not in a unit
			false
		elsif @pattern[:generate] then
			true
		else
			false
		end # if
end # generatable_unit_file?
end # FileArgument

class TestExecutable < FileArgument # executable / testable ruby unit with executable
include Virtus.value_object
values do
	attribute :test_type, Symbol, :default => 'unit' # is this a virtus bug? automatic String to Symbol conversion
	attribute :ruby_interpreter, RubyInterpreter, :default => RubyInterpreter::Preferred
#	attribute :test, String, :default => nil # all tests in file
end # values
module ClassMethods
def new_from_path(argument_path,
		test_type = :unit,
		repository = Repository::This_code_repository)
	unit = Unit.new_from_path(argument_path)
	new_executable = TestExecutable.new(argument_path: argument_path, 
								unit: unit,
								test_type: test_type,
								repository: repository)
end # new_from_path
end # ClassMethods
extend ClassMethods
def regression_unit_test_file
	if generatable_unit_file? then
		RepositoryPathname.new_from_path(@unit.pathname_pattern?(@test_type)) # unit_test_path
	else
		RepositoryPathname.new_from_path(@argument_path) # nonunit file
	end # if
end # regression_unit_test_file
def recursion_danger?
	regression_unit_test_file.expand_path.to_s == File.expand_path($PROGRAM_NAME)
end # recursion_danger?
# test dirty working directory for needed regression test
# return nil if not in unit since regression testing is then impossible
def testable?
	if unit_file? then # probably can't test if not in a unit
		if recursion_danger? then
			false # terminate recursion
		elsif generatable_unit_file? && @test_type == :unit then
			true
		elsif regression_unit_test_file.to_s[-3..-1] == '.rb' then
			true
		elsif @pattern[:suffix][-8..-1] == "_test.rb" then
			true
		elsif @test_type == :unit then
			true
		else
			false
		end # if
	else
		nil # return nil if not in unit since regression testing is then impossible
	end # if
end # testable?
def regression_test
	if testable? then
		test_run = TestRun.new(TestExecutable.new(argument_path: unit_test_path)).error_score?
	end # if
end # regression_test
def log_path?(test)
	if @unit.nil? then
		@log_path = '' # empty file string
	else
		@log_path = 'log/'
		@log_path += @test_type.to_s 
		@log_path += '/' + @ruby_interpreter.minor_version
		@log_path += '/' + @ruby_interpreter.patch_version
		@log_path += '/' + @ruby_interpreter.logging.to_s
		if test.nil? then
			Pathname.new(@log_path).mkpath
			@log_path += '/' + @unit.model_basename.to_s + '.log'
		else
			@log_path += '/' + @unit.model_basename.to_s
			Pathname.new(@log_path).mkpath
			@log_path += '/' + test.to_s + '.log'
		end # if
	end # if
	@log_path
end # log_path?
def ruby_test_string(test)
	case @ruby_interpreter.logging 
	when :silence then @ruby_test_string = 'ruby -v -W0 '
	when :medium then @ruby_test_string = 'ruby -v -W1 '
	when :verbose then @ruby_test_string = 'ruby -v -W2 '
	else fail Exception.new(logging.to_s + ' is not a valid logging type.')
	end # case
	@ruby_test_string += regression_unit_test_file.to_s
	if test.nil? then
		@ruby_test_string
	else
		@ruby_test_string += ' --name ' + test.to_s
	end # if
end # ruby_test_string
def all_test_names
	grep_run = ShellCommands.new('grep "^def test_" ' + regression_unit_test_file.to_s)
	test_names = grep_run.output.split("\n").map do |line|
		line[4..-1]
	end # map
end # all_test_names
def all_library_method_names
	grep_run = ShellCommands.new('grep "def " ' + RepositoryPathname.new_from_path(@unit.pathname_pattern?(:model)).to_s)
	test_names = grep_run.output.split("\n").map do |line|
		line[4..-1]
	end # map
	
end # all_library_method_names
# log_file => String
# Filename of log file from test run
module Examples
#include Constants
TestTestExecutable = TestExecutable.new_from_path(__FILE__) # used as Example in TestRun avoiding recursion_danger
TestSelf = TestExecutable.new(argument_path: $PROGRAM_NAME)
Not_unit = TestExecutable.new(argument_path: '/dev/null')
Not_unit_executable = TestExecutable.new(argument_path: 'test/data_sources/unit_maturity/success.rb')
TestMinimal  = TestExecutable.new(argument_path: 'test/unit/minimal2_test.rb')
Unit_non_executable = TestExecutable.new(argument_path: 'log/unit/2.2/2.2.3p173/silence/test_executable.log')
Ignored_data_source =  TestExecutable.new(argument_path: 'log/unit/2.2/2.2.3p173/silence/CA_540_2014_example-1.jpg')
end # Examples
end # TestExecutable

