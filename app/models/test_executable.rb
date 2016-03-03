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
class FileArgument
include Virtus.model
	attribute :argument_path, Pathname
	attribute :unit, Unit, :default => 	lambda { |argument, attribute| Unit.new_from_path(argument.argument_path) }
	attribute :pattern, Symbol, :default => 	lambda { |argument, attribute| FilePattern.find_from_path(argument.argument_path) }
#	attribute :test_type, Symbol, :default => 	lambda { |argument, attribute| (argument.pattern.nil? ? :non_unit : argument.pattern[:name]) }
	attribute :repository, Repository, :default => Repository::This_code_repository
module Examples
TestSelf = FileArgument.new(argument_path: $PROGRAM_NAME)
Not_unit = FileArgument.new(argument_path: '/dev/null')
Not_unit_executable = FileArgument.new(argument_path: 'test/data_sources/unit_maturity/success.rb')
TestMinimal  = FileArgument.new(argument_path: 'test/unit/minimal2_test.rb')
Unit_non_executable = FileArgument.new(argument_path: 'log/unit/2.2/2.2.3p173/silence/test_executable.log')
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
def regression_unit_test_file
	if unit_file? then
			@unit.pathname_pattern?(@test_type) # unit_test_path
	else
		File.expand_path(@argument_path) # nonunit file
	end # if
end # regression_unit_test_file
def recursion_danger?
	File.expand_path(regression_unit_test_file) == File.expand_path($PROGRAM_NAME)
end # recursion_danger?
end # FileArgument


class TestExecutable < FileArgument # executable / testable ruby unit with executable
include Virtus.value_object
values do
	attribute :test_type, Symbol, :default => 'unit' # is this a virtus bug? automatic String to Symbol conversion
	attribute :ruby_interpreter, RubyInterpreter, :default => RubyInterpreter::Preferred
	attribute :test, String, :default => nil # all tests in file
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
# test dirty working directory for needed regression test
# return nil if not in unit since regression testing is then impossible
def testable?(recursion_danger = nil)
	if unit_file? then # probably can't test if not in a unit
		if !recursion_danger.nil? &&(@argument_path == $PROGRAM_NAME) then
			false # terminate recursion
		elsif @test_type == :unit then
			true
		elsif @pattern[:suffix][-8..-1] == "_test.rb" then
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
def log_path?
	if @unit.nil? then
		@log_path = '' # empty file string
	else
		@log_path = 'log/'
		@log_path += @test_type.to_s 
		@log_path += '/' + @ruby_interpreter.minor_version
		@log_path += '/' + @ruby_interpreter.patch_version
		@log_path += '/' + @ruby_interpreter.logging.to_s
		Pathname.new(@log_path).mkpath
		@log_path += '/' + @unit.model_basename.to_s + '.log'
	end # if
	@log_path
end # log_path?
def ruby_test_string
	case @ruby_interpreter.logging 
	when :silence then @ruby_test_string = 'ruby -v -W0 '
	when :medium then @ruby_test_string = 'ruby -v -W1 '
	when :verbose then @ruby_test_string = 'ruby -v -W2 '
	else fail Exception.new(logging.to_s + ' is not a valid logging type.')
	end # case
	@ruby_test_string += regression_unit_test_file
end # ruby_test_string
def error_file(recent_test)
	ret = @repository.current_branch_name?.to_s
	ret += "\n" + Time.now.strftime("%Y-%m-%d %H:%M:%S.%L")
	ret += "\n" + recent_test.command_string
	ret += "\n" + recent_test.output.to_s
	ret += "\n" + recent_test.errors
end # error_file
def write_error_file(recent_test)
	IO.write(log_path?, error_file(recent_test))
end # write_error_file
def commit_message(recent_test, files)
	commit_message= 'fixup! ' + Unit.unit_names?(files).uniq.join(', ')
	if !recent_test.nil? then
		commit_message += "\n" + @repository.current_branch_name?.to_s + "\n"
		commit_message += "\n" + recent_test.command_string
		commit_message += "\n" + recent_test.output.to_s
		commit_message += recent_test.errors
	end #if
end # commit_message
def write_commit_message(recent_test, files)
	IO.binwrite('.git/GIT_COLA_MSG', commit_message(recent_test, files))	
end # write_commit_message
# log_file => String
# Filename of log file from test run
module Examples
#include Constants
TestTestExecutable = TestExecutable.new_from_path($PROGRAM_NAME)
TestSelf = TestExecutable.new(argument_path: $PROGRAM_NAME)
Not_unit = TestExecutable.new(argument_path: '/dev/null')
Not_unit_executable = TestExecutable.new(argument_path: 'test/data_sources/unit_maturity/success.rb')
TestMinimal  = TestExecutable.new(argument_path: 'test/unit/minimal2_test.rb')
Unit_non_executable = TestExecutable.new(argument_path: 'log/unit/2.2/2.2.3p173/silence/test_executable.log')
end # Examples
end # TestExecutable

