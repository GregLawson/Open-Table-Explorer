###########################################################################
#    Copyright (C) 2011-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative '../../app/models/no_db.rb'
require 'virtus'
require 'fileutils'
require_relative '../../app/models/repository.rb'
require_relative '../../app/models/bug.rb'
class TestRun # < ActiveRecord::Base
module Constants
Ruby_version = ShellCommands.new('ruby --version').output.split(' ')
end # Constants
include Constants
include Virtus.model
  attribute :test_type, Symbol, :default => :unit
  attribute :singular_table, String, :default => TE.model_name?
  attribute :plural_table, String, :default => nil
  attribute :test, String, :default => nil # all tests in file
  attribute :test_processor, String, :default => 'ruby'
  attribute :processor_version, String, :default => nil # system version
  attribute :options, String, :default => nil
  attribute :timestamp, Time, :default => Time.now
#include Generic_Table
#has_many :bugs
module ClassMethods
def error_score?(executable=@related_files.model_test_pathname?)
	@recent_test=shell_command("ruby "+executable)
#	@recent_test.puts if $VERBOSE
	if @recent_test.success? then
		0
	elsif @recent_test.process_status.exitstatus==1 then # 1 error or syntax error
		syntax_test=shell_command("ruby -c "+executable)
		if syntax_test.output=="Syntax OK\n" then
			initialize_test=shell_command("ruby "+executable+' -n test_initialize')
			if initialize_test.success? then
				1
			else # initialization  failure or test_initialize failure
				100 # may prevent other tests from running
			end #if
		else
			10000 # syntax error can hide many sins
		end #if
	else
		@recent_test.process_status.exitstatus # num_errors>1
	end #if
end # error_score
def ruby_run_and_log(ruby_source,log_file,test=nil, options = nil)
	file_pattern = FilePattern.find_from_path(ruby_source)
	unit = Unit.new_from_File(ruby_source)
	log_file = unit.pathname_pattern?(:library_log)
	mkdir_p(File.dirname(log_file))
	if test.nil? then
		ruby_test=ruby_source
	else
		ruby_test="#{ruby_source} -n #{test}"
	end #if
	puts "ruby_test=#{ruby_test}"
	run = 
	stop=ruby %Q{-I test #{ruby_test} | tee #{log_file}}  do |ok, res|
		if  ok
#		puts "ruby ok(status = #{res.inspect})"
			#~ sh "git add #{ruby_source}"
			 puts "IO.read('#{log_file}')='#{IO.read(log_file)}'"
		else
			puts "ruby failed(status = #{res.exitstatus})!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			#~ sh "tail --lines=2 #{log_file}"
		end
#		puts "calling file_bug_reports"
		stop=TestRun.file_bug_reports(ruby_source,log_file,test)
		#c#		puts "local_variables=#{local_variables.inspect}"
		return stop
	end # ruby
	if local_variables.include?('stop') then
		puts "stop is defined here."
		return stop
	else
		puts "stop is nil or undefined? local_variables=#{local_variables.inspect}"
		puts "Did ruby block not execute?"
		return true
	end
rescue StandardError => exception_raised
	puts  '-StandardError Error: ' + exception_raised.inspect 
	puts exception_raised.backtrace.join("\n")

	return true
rescue SyntaxError => exception_raised
	puts  '-SyntaxError Error: ' + exception_raised.inspect 
	return true
end # ruby_run_and_log
def shell(command, &proc)
#	puts "command='#{command}'"
	run =ShellCommands.new(command)
	if block_given? then
		proc.call(run)
	else
		run.assert_post_conditions
	end # if
end #shell
# Run rubyinterpreter passing arguments
def ruby(args, &proc)
	shell("ruby #{args}",&proc)
end #ruby
def file_bug_reports(ruby_source,log_file,test=nil)
	table,test_type=CodeBase.test_type_from_source(ruby_source)
	header,errors,summary=parse_log_file(log_file)
	if summary.nil? then
		puts "summary is nil. probable rake failure."
		stop=true
	else
		sysout,run_time=TestRun.parse_header(header)
		puts "sysout='#{sysout.inspect}'"
		puts "run_time='#{run_time}'"
		tests,assertions,failures,tests_stop_on_error=TestRun.parse_summary(summary)
		#~ puts "failures+tests_stop_on_error=#{failures+tests_stop_on_error}"
		if    (failures+tests_stop_on_error)==0 then
			stop=false
		else
			stop=true
		end #if
		open('db/tests.sql',"a" ) {|f| f.write("insert into test_runs(model,test,test_type,environment,tests,assertions,failures,tests_stop_on_error,created_at,updated_at) values('#{table}','#{ENV["TEST"]}','#{test_type}','#{ENV["RAILS_ENV"]}',#{tests},#{assertions},#{failures},#{tests_stop_on_error},'#{Time.now.rfc2822}','#{Time.now.rfc2822}');\n") }
	end #if
	if !errors.nil? then
		errors.each do |error|
			Bug.new(test_type,table,error)
#			puts "error='#{error}'"
		end #each
	end #if 
#	puts "ARGF.argv.inspect=#{ARGF.argv.inspect}"
	puts "file_bug_reports stop=#{stop}"
	puts "summary='#{summary}'"
	return stop
end #file_bug_reports
def parse_log_file(log_file)
	blocks=IO.read(log_file).split("\n\n")# delimited by multiple successive newlines
#	puts "blocks=#{blocks.inspect}"
	header= blocks[0]
	errors=blocks[1..-2]
	summary=blocks[-1]
	return [header,errors,summary]
end #parse_log_file
def log_passed?(log_file)
	if !File.size?(log_file) then
		return false # no file or empty file, no evidence of passing
	end #if
	header,errors,summary=TestRun.parse_log_file(log_file)
	if summary.nil? then
		return false
	else
		tests,assertions,failures,tests_stop_on_error=TestRun.parse_summary(summary)
		if    (failures+tests_stop_on_error)==0 then
			return true
		else
			return false
		end #if
	end #if
end #def
def summarize
	sh %Q(ls -1 -s log/{unit,functional}|grep " 0 "|cut --delim=' ' -f 3 >log/empty_tests.tmp)	
	sh %Q{grep "[0-9 ,][0-9 ][1-9] error" log/{unit,functional}/* | cut --delim='/' -f 3  >log/error_tests.tmp}
	sh %Q{grep "[0-9 ,][0-9 ][1-9] failures," log/{unit,functional}/* | cut --delim='/' -f 3  >log/failure_tests.tmp}
	sh %Q{cat log/empty_tests.tmp log/error_tests.tmp log/failure_tests.tmp|sort|uniq >log/failed_tests.log}
end #def
def parse_summary(summary)
	summary=summary.split(' ')
	tests=summary[0].to_i
	assertions=summary[2].to_i
	failures=summary[4].to_i
	tests_stop_on_error=summary[6].to_i
	return [tests,assertions,failures,tests_stop_on_error]
end #parse_summary
def parse_header(header)
	headerArray=header.split("\n")
	sysout=headerArray[0..-2]
	run_time=headerArray[-1].split(' ')[2].to_f
	return [sysout,run_time]
end #parse_header
end # ClassMethods
extend ClassMethods
# attr_reader
def hide_initialize(testType=nil, singular_table=nil, plural_table=nil, test=nil)
	if testType.instance_of?(Hash) then
		super(testType) # actually hash of attributes
#		attributes=testType 
	else
#		super(nil) #
		if !testType.nil? then
			raise "initialize test run with bad testType=#{testType}" unless [:unit,:controller].include?(testType.to_sym)
			#~ puts "testType is not nil. testType=#{testType} singular_table=#{singular_table}"
			@test_type=testType
			if singular_table.nil? then
				if plural_table.nil? then
					@singular_table = "code_base"
					@plural_table = "code_bases"
				else
					@singular_table = plural_table.singularize
					@plural_table = plural_table
				end #if
			else
				if plural_table.nil? then
					@singular_table = singular_table
					@plural_table = singular_table.pluralize
				else
					@singular_table = singular_table
					@plural_table = plural_table
				end #if
			end #if
			#~ puts "@singular_table=#{@singular_table} @plural_table=#{@plural_table}"
			#~ model = @singular_table # canonical form since plurals are more irregular?
			#~ puts "model=#{model} self.model=#{self.model} self['model']=#{self['model']}"
			@model = @singular_table # canonical form since plurals are more irregular?
			#~ puts "model=#{model} self.model=#{self.model} self['model']=#{self['model']}"
			#~ @model = @singular_table # canonical form since plurals are more irregular?
			#~ puts "model=#{model} self.model=#{self.model} self['model']=#{self['model']}"
			#~ self['model'] = @singular_table # canonical form since class is accessible
			#~ puts "model=#{model} self.model=#{self.model} self['model']=#{self['model']}"
			@test = test 
		else
			#~ puts "nil testType"
		end #if

	end #if
#	puts "End of initialize: self=#{self.inspect}"
#	puts "End of initialize: testType=#{testType.inspect}"
end #initialize
def unit?
	Unit.new(@singular_table)
end # unit?
def test_file
	case @test_type
	when :unit
		return "test/unit/#{@singular_table}_test.rb"
	when :controller
		return "test/functional/#{@plural_table}_controller_test.rb"
	else raise "Unnown @test_type=#{@test_type} for #{self.inspect}"
	end #case
end #test_file
# log_file => String
# Filename of log file from test run
def log_file
	case @test_type
	when :unit
		unit?.pathname_pattern?(:library_log, @test)
	when :controller
		unit?.pathname_pattern?(:controller_log, @test)
	else raise "Unnown @test_type=#{@test_type} for #{self.inspect}"
	end #case
end #log_file
# Unconditionally run the test
def run
	TestRun.ruby_run_and_log(test_file,log_file,@test)
end #run
# Run a shell
def ruby_run_and_log
	TestRun.ruby_run_and_log(test_file,log_file,@test)
end #ruby_run_and_log

def file_bug_reports
	TestRun.file_bug_reports(test_file,log_file,@test)
end #file_bug_reports
require_relative '../../test/assertions.rb'
module Assertions
module ClassMethods
def assert_pre_conditions(message='')
	message+="In assert_pre_conditions, self=#{inspect}"
end #assert_pre_conditions
def assert_post_conditions(message='')
	message+="In assert_post_conditions, self=#{inspect}"
end #assert_post_conditions
end #ClassMethods
def assert_pre_conditions(message='')
end #assert_pre_conditions
def assert_post_conditions(message='')
end #assert_post_conditions
def assert_logical_primary_key_defined(instance,message=nil)
	message=build_message(message, "instance=?", instance.inspect)	
	assert_not_nil(instance, message)
	assert_instance_of(TestRun,instance, message)
	assert_kind_of(ActiveRecord::Base,instance, message)

#	puts "instance=#{instance.inspect}"
	assert_not_nil(instance.attributes, message)
	assert_not_nil(instance[:test_type], message)
	assert_not_nil(instance.test_type, message)
	assert_not_nil(instance['test_type'], message)
	assert_not_nil(instance.model, message)
end #assert_logical_primary_key_defined
end # Assertions
include Assertions
extend Assertions::ClassMethods
#self.assert_pre_conditions
module Examples
include Constants
Default_testRun = TestRun.new
Unit_testRun = TestRun.new(:test_type => :unit)
#Plural_testRun = TestRun.new({:test_type => :unit, :model => 'test_runs'})
Singular_testRun = TestRun.new(:test_type => :unit,  :singular_table => 'test_run')
Stream_pattern_testRun = TestRun.new(:test_type => :unit,  :singular_table => 'stream_pattern')
Odd_plural_testRun=TestRun.new(:test_type => :unit, :singular_table => :code_base, :plural_table => :code_bases, :test => nil)

end # Examples
end # TestRun
