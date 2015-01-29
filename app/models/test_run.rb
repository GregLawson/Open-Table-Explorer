###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'app/models/generic_table.rb'
require 'app/models/bug.rb'
class TestRun  < ActiveRecord::Base
include Generic_Table
has_many :bugs
def initialize(testType=nil, singular_table=nil, plural_table=nil, test=nil)
	if testType.instance_of?(Hash) then
		super(testType) # actually hash of attributes
#		attributes=testType 
	else
		super(nil) #
		if !testType.nil? then
			raise "initialize test run with bad testType=#{testType}" unless [:unit,:controller].include?(testType.to_sym)
			#~ puts "testType is not nil. testType=#{testType} singular_table=#{singular_table}"
			self[:test_type]=testType
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
			self.model = @singular_table # canonical form since plurals are more irregular?
			#~ puts "model=#{model} self.model=#{self.model} self['model']=#{self['model']}"
			#~ self[:model] = @singular_table # canonical form since plurals are more irregular?
			#~ puts "model=#{model} self.model=#{self.model} self['model']=#{self['model']}"
			#~ self['model'] = @singular_table # canonical form since class is accessible
			#~ puts "model=#{model} self.model=#{self.model} self['model']=#{self['model']}"
			self.test = test 
		else
			#~ puts "nil testType"
		end #if

	end #if
#	puts "End of initialize: self=#{self.inspect}"
#	puts "End of initialize: testType=#{testType.inspect}"
end #initialize
def test_file
	case self[:test_type].to_sym
	when :unit
		return "test/unit/#{@singular_table}_test.rb"
	when :controller
		return "test/functional/#{@plural_table}_controller_test.rb"
	else raise "Unnown self[:test_type]=#{self[:test_type]} for singular_table=#{singular_table}"
	end #case
end #test_file
# log_file => String
# Filename of log file from test run
def log_file
	if self[:test].nil? then
		test_suffix=''
	else
		test_suffix=".#{self[:test]}"
	end #if
	case self[:test_type].to_sym
	when :unit
		return CodeBase.unit_target(@singular_table.to_s+test_suffix)
	when :controller
		return CodeBase.controller_target(@plural_table.to_s+test_suffix)
	else raise "Unnown self[:test_type]=#{self[:test_type]} for singular_table=#{singular_table}"
	end #case
end #log_file
# Unconditionally run the test
def run
	TestRun.ruby_run_and_log(test_file,log_file,self[:test])
end #run
# Run a shell
def TestRun.shell(command, &proc)
#	puts "command='#{command}'"
	output=`#{command}`
#	puts "$?=#{$?}"
#	puts "output='#{output}'"
	if $?==0 then
		proc.call(true,output)
#		puts output
		return output
	else
		proc.call(false,"$?=#{$?}"+output)
#		puts output
		return nil
	end #if
end #shell
# Run rubyinterpreter passing arguments
def TestRun.ruby(args, &proc)
	shell("ruby #{args}",&proc)
end #ruby
def ruby_run_and_log
	TestRun.ruby_run_and_log(test_file,log_file,self[:test])
end #ruby_run_and_log

def TestRun.ruby_run_and_log(ruby_source,log_file,test=nil)
	if test.nil? then
		ruby_test=ruby_source
	else
		ruby_test="#{ruby_source} -n #{test}"
	end #if
	puts "ruby_test=#{ruby_test}"
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
end #ruby_run_and_log
def file_bug_reports
	TestRun.file_bug_reports(test_file,log_file,self[:test])
end #file_bug_reports
def TestRun.file_bug_reports(ruby_source,log_file,test=nil)
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
def TestRun.parse_log_file(log_file)
	blocks=IO.read(log_file).split("\n\n")# delimited by multiple successive newlines
#	puts "blocks=#{blocks.inspect}"
	header= blocks[0]
	errors=blocks[1..-2]
	summary=blocks[-1]
	return [header,errors,summary]
end #parse_log_file
def TestRun.log_passed?(log_file)
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
def TestRun.summarize
	sh %Q(ls -1 -s log/{unit,functional}|grep " 0 "|cut --delim=' ' -f 3 >log/empty_tests.tmp)	
	sh %Q{grep "[0-9 ,][0-9 ][1-9] error" log/{unit,functional}/* | cut --delim='/' -f 3  >log/error_tests.tmp}
	sh %Q{grep "[0-9 ,][0-9 ][1-9] failures," log/{unit,functional}/* | cut --delim='/' -f 3  >log/failure_tests.tmp}
	sh %Q{cat log/empty_tests.tmp log/error_tests.tmp log/failure_tests.tmp|sort|uniq >log/failed_tests.log}
end #def
def TestRun.parse_summary(summary)
	summary=summary.split(' ')
	tests=summary[0].to_i
	assertions=summary[2].to_i
	failures=summary[4].to_i
	tests_stop_on_error=summary[6].to_i
	return [tests,assertions,failures,tests_stop_on_error]
end #parse_summary
def TestRun.parse_header(header)
	headerArray=header.split("\n")
	sysout=headerArray[0..-2]
	run_time=headerArray[-1].split(' ')[2].to_f
	return [sysout,run_time]
end #parse_header

end #class
