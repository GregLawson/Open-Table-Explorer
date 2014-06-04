###########################################################################
#    Copyright (C) 2011 by Greg Lawson                                      
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
def test_initialize
	testRun=TestRun.new
	TestRun.column_names.each do |n|
		assert_instance_of(String,n)
	end #each
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
def test_test_file
	testRun=TestRun.new(:unit,:code_base, :code_bases,nil)
	assert_equal('test/unit/code_base_test.rb',testRun.test_file)
end #test_file
def test_log_file
	testRun=TestRun.new(:unit,:code_base, :code_bases,nil)
	assert_equal('log/unit/code_base_test.log',testRun.log_file)
end #log_file
def test_run
#	TestRun.new(:unit, 'test_run').run
end #run
def test_shell
	assert_not_empty(TestRun.shell('pwd'){|ok, res| puts ok,res})
end #shell
def test_ruby_run_and_log
#	TestRun.ruby_run_and_log('/dev/null','/dev/null')
end #ruby_run_and_log
def test_file_bug_reports
	testRun=TestRun.new(:unit,:code_base, :code_bases,nil)
	header,errors,summary=TestRun.parse_log_file(testRun.log_file)
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
	testRun=TestRun.new(:unit,:code_base, :code_bases,nil)
	blocks=IO.read(testRun.log_file).split("\n\n")# delimited by multiple successive newlines
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
	header,errors,summary=TestRun.parse_log_file(testRun.log_file)
	assert_not_nil(header)
	assert_not_nil(summary)
end #parse_log_file
def test_parse_summary
end #parse_summary
def test_parse_header
	testRun=TestRun.new(:unit,:code_base, :code_bases,nil)
	header,errors,summary=TestRun.parse_log_file(testRun.log_file)
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
def test_fixture_function_ # aaa to output first
	define_association_names #38271 associations
	assert_equal(@my_fixtures,fixtures(@table_name))
end #test
def test_general_associations
#	assert_general_associations(@table_name)
end #test
def test_id_equal
	if TE.model_class?.sequential_id? then
	else
		@my_fixtures.each_value do |ar_from_fixture|
			message="Check that logical key (#{ar_from_fixture.class.logical_primary_key}) value (#{ar_from_fixture.logical_primary_key_value}) exactly matches yaml label for record."
			message+=" identify != id. ar_from_fixture.inspect=#{ar_from_fixture.inspect} ar_from_fixture.logical_primary_key_value=#{ar_from_fixture.logical_primary_key_value}"
			assert_equal(Fixtures::identify(ar_from_fixture.logical_primary_key_value),ar_from_fixture.id,message)
		end
	end
end #def
def test_specific__stable_and_working
end #test
end #class
