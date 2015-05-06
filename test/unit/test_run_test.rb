###########################################################################
#    Copyright (C) 2011-2015 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require 'active_support' # for singularize and pluralize
require_relative '../../app/models/regexp.rb'
require_relative '../../app/models/test_run.rb'
# executed in alphabetical order. Longer names sort later.
class TestRunTest < TestCase
include TestRun::Examples
include Repository::Constants
def test_virtus_initialize
	assert_equal(Repository::This_code_repository.path, Odd_plural_testRun.repository.path)
	assert_equal(:unit, Odd_plural_testRun.test_type)
	assert_equal('code_base', Odd_plural_testRun.singular_table)
	assert_equal('code_bases', Odd_plural_testRun.plural_table)
	assert_equal(nil, Odd_plural_testRun.test)
end # virtus_initialize
def test_Constants
	assert_match(Ruby_pattern, Ruby_version)
	assert_match(Parenthetical_date_pattern, Ruby_version)
	assert_match(Bracketed_os, Ruby_version)
	assert_match(Ruby_pattern * Parenthetical_date_pattern, Ruby_version)
	assert_match(Parenthetical_date_pattern * Bracketed_os, Ruby_version)
	assert_match(Version_pattern, Ruby_version)
end # Constants
def test_ruby_version
	executable_suffix = ''
	testRun = TestRun.new(test_command: 'ruby', options: '--version').run
	parse = testRun.output.parse(Version_pattern).output
	assert_instance_of(Hash, parse)
	assert_operator(parse[:major], :>=, '1')
	assert_operator(parse[:minor], :>=, '1')
	assert_operator(parse[:patch], :>=, '1')
	assert_instance_of(String, parse[:pre_release])
end # ruby_version
def test_log_path?
	executable = $PROGRAM_NAME
	assert_equal('log/unit/1.9/1.9.3p194/quiet/repository.log', This_code_repository.log_path?(executable))
#	assert_equal('log/unit/1.9/1.9.3p194/quiet/repository.log', This_code_repository.log_path?)
end # log_path?
def test_ruby_test_string
	executable = $PROGRAM_NAME
	ruby_test_string = This_code_repository.ruby_test_string(executable)
	assert_match(executable, ruby_test_string)
end # ruby_test_string
def test_error_score?
	executable='/etc/mtab' #force syntax error with non-ruby text
	ruby_test_string = This_code_repository.ruby_test_string(executable)
	recent_test = This_code_repository.shell_command(ruby_test_string)
	error_message = recent_test.process_status.inspect+"\n"+recent_test.inspect
	assert_equal(1, recent_test.process_status.exitstatus, error_message)
	assert_equal(false, recent_test.success?, error_message)
	assert(!recent_test.success?, error_message)
		syntax_test=This_code_repository.shell_command("ruby -c "+executable)
		assert_not_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
	assert_equal(10000, This_code_repository.error_score?(executable), This_code_repository.recent_test.inspect)
#	This_code_repository.assert_deserving_branch(:edited, executable)

	executable='test/unit/minimal2_test.rb'
		recent_test=This_code_repository.shell_command("ruby "+executable)
		assert_equal(recent_test.process_status.exitstatus, 0, recent_test.inspect)
		syntax_test=This_code_repository.shell_command("ruby -c "+executable)
		assert_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
	assert_equal(0, This_code_repository.error_score?('test/unit/minimal2_test.rb'))
#	This_code_repository.assert_deserving_branch(:passed, executable)
	Error_classification.each_pair do |key, value|
		executable = Repository_Unit.data_sources_directory?+'/'+value.to_s+'.rb'
		assert_equal(key, This_code_repository.error_score?(executable), This_code_repository.recent_test.inspect)
	end #each
end # error_score
def test_ruby_run_and_log
#	executable=This_code_repository.related_files.model_test_pathname?
	executable='/etc/mtab' #force syntax error with non-ruby text
		recent_test=This_code_repository.shell_command("ruby "+executable)
		assert_equal(recent_test.process_status.exitstatus, 1, recent_test.inspect)
		syntax_test=This_code_repository.shell_command("ruby -c "+executable)
		assert_not_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
	assert_equal(10000, This_code_repository.error_score?(executable))
#	This_code_repository.assert_deserving_branch(:edited, executable)
	executable='test/unit/minimal2_test.rb'
		recent_test=This_code_repository.shell_command("ruby "+executable)
		assert_equal(recent_test.process_status.exitstatus, 0, recent_test.inspect)
		syntax_test=This_code_repository.shell_command("ruby -c "+executable)
		assert_equal("Syntax OK\n", syntax_test.output, syntax_test.inspect)
	assert_equal(0, This_code_repository.error_score?('test/unit/minimal2_test.rb'))
#	This_code_repository.assert_deserving_branch(:passed, executable)
	Error_classification.each_pair do |key, value|
		executable=data_source_directory?+'/'+value.to_s+'.rb'
		assert_equal(key, This_code_repository.error_score?(executable), This_code_repository.recent_test.inspect)
	end #each
end # ruby_run_and_log
def test_shell
	assert_not_empty(TestRun.shell('pwd'){|run| run.inspect})
end #shell
def test_file_bug_reports
	header,errors,summary=TestRun.parse_log_file(Odd_plural_testRun.log_file?)
	headerArray=header.split("\n")
	assert_instance_of(Array, headerArray)
	sysout=headerArray[0..-2]
	assert_instance_of(Array, sysout)
	assert_equal(headerArray.size,sysout.size+1)
	run_time=headerArray[-1].split(' ')[2]
	assert_equal('Finished',headerArray[-1].split(' ')[0],"headerArray='#{headerArray.inspect}', header='#{header.inspect}'")
	assert_equal('in',headerArray[-1].split(' ')[1])
	assert_equal('seconds.',headerArray[-1].split(' ')[3])
	sysout,run_time=TestRun.parse_header(header)
	assert_instance_of(Array, sysout)
	assert_not_nil(run_time)
	assert_operator(run_time, :>=, 0)
	sysout,run_time=TestRun.parse_header(header)
	assert_not_nil(run_time)
	assert_operator(run_time, :>=, 0)
end #file_bug_reports
def test_parse_log_file
	log_file = Default_testRun.log_file?
	blocks=IO.read(log_file).split("\n\n")# delimited by multiple successive newlines
#	puts "blocks='#{blocks.inspect}'"
	header= blocks[0]
	errors=blocks[1..-2]
	summary=blocks[-1]
	headerArray=header.split("\n")
	assert_instance_of(Array, headerArray)
	assert_operator(headerArray.size,:>,1)
	sysout=headerArray[0..-2]
	assert_instance_of(Array, sysout)
	assert_equal(headerArray.size,sysout.size+1)
	run_time=headerArray[-1].split(' ')[2]
	assert_equal('Finished',headerArray[-1].split(' ')[0],"headerArray[-1]='#{headerArray[-1].inspect}'")
	assert_equal('in',headerArray[-1].split(' ')[1])
	assert_equal('seconds.',headerArray[-1].split(' ')[3])
	sysout,run_time=TestRun.parse_header(header)
	assert_instance_of(Array, sysout)
	assert_not_nil(run_time)
	assert_operator(run_time, :>=, 0)
	sysout,run_time=TestRun.parse_header(header)
	assert_not_nil(run_time)
	assert_operator(run_time, :>=, 0)
	header,errors,summary=TestRun.parse_log_file(testRun.log_file?)
	assert_not_nil(header)
	assert_not_nil(summary)
end #parse_log_file
def test_parse_summary
end #parse_summary
def test_parse_header
	header,errors,summary=TestRun.parse_log_file(Odd_plural_testRun.log_file?)
	assert_operator(header.size,:>,0)
	headerArray=header.split("\n")
	assert_instance_of(Array, headerArray)
	sysout=headerArray[0..-2]
	assert_instance_of(Array, sysout)
	assert_equal(headerArray.size,sysout.size+1)
	run_time=headerArray[-1].split(' ')[2]
	assert_equal('Finished',headerArray[-1].split(' ')[0],"headerArray[-1]='#{headerArray[-1].inspect}'")
	assert_equal('in',headerArray[-1].split(' ')[1])
	assert_equal('seconds.',headerArray[-1].split(' ')[3])
	sysout,run_time=TestRun.parse_header(header)
	assert_instance_of(Array, sysout)
	assert_not_nil(run_time)
	assert_operator(run_time, :>=, 0)
end #parse_header
def test_initialize
	testRun=TestRun.new
#	TestRun.column_names.each do |n|
#		assert_instance_of(String,n)
#	end #each
	# prove equivalence of attribute access
	assert_respond_to(testRun, 'singular_table')
	testRun.singular_table='method'
	assert_equal('method', testRun.singular_table)
	assert_equal('method', testRun.attributes[:singular_table])
	assert_nil(testRun.attributes['singular_table'])
	
	testRun[:singular_table]='sym_hash'
	assert_equal('sym_hash', testRun.singular_table)
	assert_equal('sym_hash', testRun[:singular_table])
	
	testRun['singular_table']='string_hash'
	assert_equal('string_hash', testRun.singular_table)
	assert_equal('string_hash', testRun[:singular_table])
	
	Singular_testRun.assert_logical_primary_key_defined
	Stream_pattern_testRun.assert_logical_primary_key_defined()
	Unit_testRun.assert_logical_primary_key_defined()
end #initialize
def test_test_file?
	assert_equal('test/unit/code_base_test.rb',Odd_plural_testRun.test_file?)
end #test_file?
def test_log_file
	test_virtus_initialize
	assert_equal(:unit, Odd_plural_testRun.test_type)
	assert_equal('code_base', Odd_plural_testRun.singular_table)
	assert_equal(:code_base, Odd_plural_testRun.unit?.model_class_name, Odd_plural_testRun.inspect)
	assert_equal(:code_base, Odd_plural_testRun.unit?.model_class_name.to_s.underscore.to_sym, Odd_plural_testRun.inspect)

	assert_equal(:code_base, Odd_plural_testRun.unit?.model_basename, Odd_plural_testRun.inspect)
	assert_equal(File.expand_path('log/library/code_base.log'), Odd_plural_testRun.log_file, Odd_plural_testRun.inspect)
end #log_file
def test_run
	assert_equal("test/unit/test_run_test.rb\n", TestRun.new(test_command: 'echo', options: '').run.output)
	ruby_pattern = /ruby / * /2.1.2p95/
	parenthetical_date_pattern = / \(/ * /2014-05-08/.capture(:compile_date) * /\)/
	bracketed_os = / \[/ * /i386-linux-gnu/ * /\]/ * "\n"
	version_pattern = ruby_pattern * parenthetical_date_pattern * bracketed_os
	assert_match(ruby_pattern, TestRun.new(test_command: 'ruby', options: '--version').run.output)
	assert_match(parenthetical_date_pattern, TestRun.new(test_command: 'ruby', options: '--version').run.output)
	assert_match(bracketed_os, TestRun.new(test_command: 'ruby', options: '--version').run.output)
	assert_match(ruby_pattern * parenthetical_date_pattern, TestRun.new(test_command: 'ruby', options: '--version').run.output)
	assert_match(parenthetical_date_pattern * bracketed_os, TestRun.new(test_command: 'ruby', options: '--version').run.output)
	assert_match(version_pattern, TestRun.new(test_command: 'ruby', options: '--version').run.output)
	output = TestRun.new(test_command: 'ruby', singular_table: 'unit').run.assert_post_conditions.output
	unit_run = TestRun.new(test_command: 'ruby', singular_table: 'unit').run
	assert_equal(0, unit_run.process_status, unit_run.inspect)
	unit_run.assert_post_conditions
	output = unit_run.output
	tests_pattern = /[0-9]+/.capture(:tests) * / / * /tests/
	assertions_pattern = /[0-9]+/.capture(:assertions) * / / * /assertions/
	failures_pattern = /[0-9]+/.capture(:failures) * / / * /failures/
	errors_pattern = /[0-9]+/.capture(:errors) * / / * /errors/
	pendings_pattern = /[0-9]+/.capture(:pendings) * / / * /pendings/
	omissions_pattern = /[0-9]+/.capture(:omissions) * / / * /omissions/
	notifications_pattern = /[0-9]+/.capture(:notifications) * / / * /notifications/
	output_pattern = [tests_pattern, assertions_pattern, failures_pattern, errors_pattern,pendings_pattern]
	output_pattern += [omissions_pattern, notifications_pattern]
	test_results = output.parse(output_pattern)
	assert_instance_of(Array, test_results)
end #run
end # TestRun
