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
	attribute :executable_file, String
	attribute :unit, Unit, :default => 	lambda { |argument, attribute| Unit.new_from_path(argument.executable_file) }
#	attribute :test_type, Symbol, :default => 'unit' # is this a virtus bug? automatic String to Symbol conversion
	attribute :pattern, Symbol, :default => 	lambda { |argument, attribute| FilePattern.find_from_path(argument.executable_file) }
	attribute :test_type, Symbol, :default => 	lambda { |argument, attribute| (argument.pattern.nil? ? :non_unit : argument.pattern[:name]) }
	attribute :repository, Repository, :default => Repository::This_code_repository
module Examples
Executable = FileArgument.new(executable_file: $0)
Non_executable = FileArgument.new(executable_file: '/dev/null')
end # Examples
end # FileArgument


class TestExecutable < FileArgument # executable / testable ruby unit with executable
  include Virtus.value_object
  values do
  attribute :ruby_interpreter, RubyInterpreter, :default => RubyInterpreter::Preferred
	attribute :test, String, :default => nil # all tests in file
	end # values
module ClassMethods
def new_from_path(executable_file,
		repository = Repository::This_code_repository)
	new_executable = TestExecutable.new(executable_file: executable_file, 
								repository: repository)
end # new_from_path
end # ClassMethods
extend ClassMethods
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
	@ruby_test_string += executable_file
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
Default_executable = TestExecutable.new_from_path($PROGRAM_NAME)
end # Examples
end # TestExecutable

