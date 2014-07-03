###########################################################################
#    Copyright (C) 2011-2014 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require 'active_support' # for singularize and pluralize
require_relative '../../app/models/test_run.rb'
# executed in alphabetical order. Longer names sort later.
class TestRunTest < TestCase
include TestRun::Examples
include Repository::Constants
def test_virtus_initialize
	assert_equal(:unit, Odd_plural_testRun.test_type)
	assert_equal('code_base', Odd_plural_testRun.singular_table)
	assert_equal('code_bases', Odd_plural_testRun.plural_table)
	assert_equal(nil, Odd_plural_testRun.test)
end # virtus_initialize
def test_error_score?
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
	assert_respond_to(testRun, 'model')
	testRun.model='method'
	assert_equal('method', testRun.model)
	assert_equal('method', testRun[:model])
	assert_equal('method', testRun['model'])
	
	testRun[:model]='sym_hash'
	assert_equal('sym_hash', testRun.model)
	assert_equal('sym_hash', testRun[:model])
	assert_equal('sym_hash', testRun['model'])
	
	testRun['model']='string_hash'
	assert_equal('string_hash', testRun.model)
	assert_equal('string_hash', testRun[:model])
	assert_equal('string_hash', testRun['model'])
	
	assert_logical_primary_key_defined(TestRun.new({:test_type => :unit, :model => 'test_runs'}))
	assert_logical_primary_key_defined(TestRun.new(:unit, 'stream_pattern'))
	assert_logical_primary_key_defined(TestRun.new(:unit, 'test_run'))
	test=TestRun.new(:unit)
	assert_logical_primary_key_defined(test)
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
	Unit_testRun.run.assert_post_conditions
end #run
end # TestRun
