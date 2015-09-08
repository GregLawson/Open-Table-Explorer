###########################################################################
#    Copyright (C) 2011-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/test_executable.rb'
require_relative '../../app/models/no_db.rb'
require 'virtus'
require 'fileutils'
require_relative '../../app/models/repository.rb'
require_relative '../../app/models/ruby_interpreter.rb'
require_relative '../../app/models/shell_command.rb'
require_relative '../../app/models/branch.rb'
class TestExecutable
include Virtus.model
	attribute :test_type, Symbol, :default => 'unit' # is this a virtus bug? automatic String to Symbol conversion
	attribute :singular_table, String
	attribute :plural_table, String, :default => nil
	attribute :test, String, :default => nil # all tests in file
	attribute :test_command, String, :default => 'ruby'
	attribute :processor_version, String, :default => nil # system version
	attribute :options, String, :default => '-W0'
	attribute :timestamp, Time, :default => Time.now
	attribute :repository, Repository, :default => Repository::This_code_repository
	attribute :executable_file, String
	attribute :unit, Unit
module ClassMethods
def new_from_path(executable_file,
		repository = Repository::This_code_repository)
	unit = Unit.new_from_path?(executable_file)
	new_executable = TestExecutable.new(executable_file: executable_file, 
								unit: unit, repository: repository)
end # new_from_path
end # ClassMethods
extend ClassMethods
def log_path?(logging = :quiet,
		minor_version = '1.9',
		patch_version = '1.9.3p194')
	@unit = Unit.new_from_path?(executable_file)
	if @unit.nil? then
		@log_path = '' # empty file string
	else
		@log_path = 'log/'
		@log_path += @test_type.to_s 
		@log_path += '/' + minor_version
		@log_path += '/' + patch_version
		@log_path += '/' + logging.to_s
		@log_path += '/' + @unit.model_basename.to_s + '.log'
		end # if
end # log_path?
def ruby_test_string(logging = :quiet,
		minor_version = '1.9',
		patch_version = '1.9.3p194')
	case logging 
	when :silence then @ruby_test_string = 'ruby -v -W0 '
	when :medium then @ruby_test_string = 'ruby -v -W1 '
	when :verbose then @ruby_test_string = 'ruby -v -W2 '
	else fail Exception.new(logging + ' is not a valid logging type.')
	end # case
	@ruby_test_string += executable_file
end # ruby_test_string
def write_error_file(recent_test, log_path)
	contents = @repository.current_branch_name?.to_s
	contents += "\n" + Time.now.strftime("%Y-%m-%d %H:%M:%S.%L")
	contents += "\n" + recent_test.command_string
	contents += "\n" + recent_test.output
	contents += "\n" + recent_test.errors
	IO.write(log_path, contents)
end # write_error_file
def write_commit_message(recent_test,files)
	commit_message= 'fixup! ' + Unit.unit_names?(files).uniq.join(', ')
	if !recent_test.nil? then
		commit_message += "\n" + @repository.current_branch_name?.to_s + "\n"
		commit_message += "\n" + recent_test.command_string
		commit_message += "\n" + recent_test.output
		commit_message += recent_test.errors
	end #if
	IO.binwrite('.git/GIT_COLA_MSG', commit_message)	
end # write_commit_message
def unit?
	Unit.new(@singular_table)
end # unit?
# log_file => String
# Filename of log file from test run
def test_file?
	case @test_type
	when :unit
		return "test/unit/#{@singular_table}_test.rb"
	when :controller
		return "test/functional/#{@plural_table}_controller_test.rb"
	else raise "Unnown @test_type=#{@test_type} for #{self.inspect}"
	end #case
end #test_file?
module Examples
#include Constants
Default_executable = TestExecutable.new_from_path($PROGRAM_NAME)
Unit_executable = TestExecutable.new(:test_type => :unit)
Plural_executable = TestExecutable.new({:test_type => :unit, :plural_table => 'test_runs'})
Singular_executable = TestExecutable.new(:test_type => :unit,  :singular_table => 'test_run')
Odd_plural_executable = TestExecutable.new(:test_type => :unit, :singular_table => :code_base, :plural_table => :code_bases, :test => nil)
end # Examples
end # TestExecutable

