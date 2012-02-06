###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require 'test/test_helper'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class StreamMethod < ActiveRecord::Base
include Test::Unit::Assertions
require 'rails/test_help'
def assert_no_syntax_error(code)
	method_def= "def syntax_check_temp_method\n#{code}\nend\n"
	instance_eval(method_def)
	return true
rescue  SyntaxError => exception_raised
	return false
end #def

def assert_acq_and_rescue
	stream=acquisition_stream_specs(@testURL.to_sym)
	acq=ruby_interfaces(:HTTP)
	acq.interface_method
	assert(!acq.interaction.error.nil? || !acq.interaction.acquisition_data.empty?)
rescue  StandardError => exception_raised
	puts 'Error: ' + exception_raised.inspect + ' could not get data from '+stream.url
	puts "$!=#{$!}"
end #def	  
def assert_gui_name
	acq=stream_methods(:HTTP)
	assert_equal("@input", acq.gui_name('input'))
end #gui_name
def assert_instance_name_reference
	acq=stream_methods(:HTTP)
	assert_equal("self[:input]", acq.instance_name_reference('input'))
end #instance_name_reference
def assert_default_method
	acq=stream_methods(:HTTP)
	assert_equal('@acquisition=@uri', acq.default_method)
end #default_method
def assert_map_io
	acq=stream_methods(:HTTP)
	code=acq.default_method
	name='uri'
	assert_equal('@acquisition=self[:uri]', code.gsub(acq.gui_name(name), acq.instance_name_reference(name)))
	name='acquisition'
	assert_equal('self[:acquisition]=@uri', code.gsub(acq.gui_name(name), acq.instance_name_reference(name)))
	name='uri'
	code=code.gsub(acq.gui_name(name), acq.instance_name_reference(name))
	assert_equal('@acquisition=self[:uri]', code.gsub(acq.gui_name(name), acq.instance_name_reference(name)))
	name='acquisition'
	code=code.gsub(acq.gui_name(name), acq.instance_name_reference(name))
	assert_equal('self[:acquisition]=self[:uri]', code.gsub(acq.gui_name(name), acq.instance_name_reference(name)))
	assert_equal('', acq.map_io(''))
	assert_equal('self[:acquisition]=self[:uri]', acq.map_io(acq.default_method))
end #map_io
def assert_eval_method
	acq=stream_methods(:HTTP)
	code=acq.interface_code
	if code.nil? || code.empty? then
		rows=0
		cols=0
	else
		code_lines=code.split("\n")
		rows=code_lines.size
		cols=code_lines.map {|l|l.length}.max
	end #if
	assert_operator(rows,:>,0)
	assert_operator(cols,:>,0)
	acq.compile_code!
	explain_assert_respond_to(acq,:interface_code_method)
	assert_include('interface_code_method',acq.methods(true))
#	acq.eval_method(:interface_code,'')
	assert_include('interface_code_rows',acq.methods(true))
	assert_include('interface_code_rows',acq.singleton_methods(true))
	explain_assert_respond_to(acq,:interface_code_rows)
	assert_not_nil(acq.interface_code_rows)
end #eval_method
def assert_compile_code
	acq=stream_methods(:HTTP)
	assert_instance_of(StreamMethod,acq)
#	puts "acq.matching_methods(/code/).inspect=#{acq.matching_methods(/code/).inspect}"
	acq.compile_code!
	assert_not_nil(acq)
	@my_fixtures.each_value do |acq|
		assert_instance_of(StreamMethod,acq)
#		puts "acq.matching_methods(/code/).inspect=#{acq.matching_methods(/code/).inspect}"
		acq.compile_code!
		#~ if acq.self[:errorz]=self[:errorz].empty? then
			#~ puts "No error in acq=#{acq.interface_code.inspect}"
		#~ else
			#~ puts "acq.self[:errorz]=self[:errorz]=#{acq.self[:errorz]=self[:errorz].inspect} for acq=#{acq.interface_code.inspect}"
		#~ end #if
		assert_not_nil(acq)
		assert(!acq.respond_to?(:syntax_check_temp_method),"syntax_check_temp_method is a method of #{canonicalName}.")
	end #each_value
end #compile_code
def assert_input_stream_names
	acq=stream_methods(:HTTP)
	stream_pattern_arguments=acq.stream_pattern.stream_pattern_arguments
	stream_inputs=stream_pattern_arguments.select{|a| a.direction=='Input'}
	assert_equal(['URI'], stream_inputs.map{|a| a.name})
	assert_equal(['uri'], acq.input_stream_names)

end #input_stream_names
def assert_output_stream_names
	acq=stream_methods(:HTTP)
	stream_pattern_arguments=acq.stream_pattern.stream_pattern_arguments
	stream_outputs=stream_pattern_arguments.select{|a| a.direction=='Output'}
	assert_equal(['Acquisition'], stream_outputs.map{|a| a.name})
	assert_equal(['acquisition'], acq.output_stream_names)

end #output_stream_names
def fire_check(interface_code, interface_code_errors, acquisition_errors)
	stream_method=StreamMethod.new
	stream_method[:interface_code]=interface_code
	assert_instance_of(StreamMethod,stream_method)
#	puts "stream_method.matching_methods(/code/).inspect=#{stream_method.matching_methods(/code/).inspect}"
	stream_method.compile_code!
	stream_method[:uri]='http://192.168.100.1'
	assert(stream_method.has_attribute?(:uri))
	assert(!stream_method.has_attribute?(:errors))
	assert_equal(ActiveModel::Errors.new('err'), stream_method.errors)
	assert_equal([], stream_method.errors.full_messages)

	firing=stream_method.fire!
	assert_equal(interface_code_errors, firing.errors[:interface_code],"interface_code=#{firing[:interface_code]}")
	assert_equal(acquisition_errors, firing.errors[:acquisition])
	assert_not_empty(firing.errors)
	assert_not_empty(firing.errors.inspect)
	assert_instance_of(ActiveModel::Errors, firing.errors)
	assert_instance_of(Array, firing.errors.full_messages)
	assert_instance_of(StreamMethod, firing)
	assert_kind_of(StreamMethod, firing)
	assert_equal(firing, stream_method)
	assert_equal('http://192.168.100.1', firing.uri)
	firing.errors.clear # so we can run more tests
end #fire_check
def assert_fire
	acq=stream_methods(:HTTP)
	fire_check(acq.interface_code, ['#<NoMethodError: undefined method `uri\' for "http://192.168.100.1":String>'], ['is empty.'])
	fire_check(acq.default_method, [], [])
	assert_equal("http://192.168.100.1", acq[:acquisition])
	@my_fixtures.each_pair do |key, sm|
		assert_instance_of(StreamMethod, sm)
		fire_check(sm.default_method, [], [])
	end #each
end #fire
def assert_errors
	acq=stream_methods(:HTTP)
	assert(!acq.has_attribute?(:errors))
	assert_instance_of(ActiveModel::Errors, acq.errors)
	assert_instance_of(Array, acq.errors.full_messages)
	assert_equal({}, acq.errors)
	assert_equal([], acq.errors.full_messages)
	acq.errors.add(:acquisition,"is bad.")
	assert_equal(["Acquisition is bad."], acq.errors.full_messages)
#fails	assert_equal({[:acquisition, ["is bad."]]=>nil}, acq.errors)
#fails	assert_equal({[:acquisition, ["is bad."]]=>nil}.inspect, acq.errors.to_hash.inspect)
	acq.errors.add(:errors,"is worse.")
	assert_equal(2, acq.errors.count)
	assert_equal(["is bad."], acq.errors[:acquisition])
	assert_equal(["is worse."], acq.errors[:errors])
	assert_equal([:acquisition, :errors], acq.errors.keys)
	assert_equal("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<errors>\n  <error>Acquisition is bad.</error>\n  <error>Errors is worse.</error>\n</errors>\n", acq.errors.to_xml)
#fails	assert_equal({[:acquisition, ["is bad."]]=>nil, [:errors, ["is worse."]]=>nil}, acq.errors.as_json)
	assert_equal(["Acquisition is bad.", "Errors is worse."], acq.errors.full_messages)
	assert_equal(["Acquisition is bad.", "Errors is worse."], acq.errors.to_a)
	acq.errors.clear      
	assert_equal(0, acq.errors.count)
end #errors

end #StreamMethod