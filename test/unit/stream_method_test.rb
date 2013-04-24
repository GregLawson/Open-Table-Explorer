###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative 'default_test_case.rb'
require_relative '../assertions/stream_method_assertions.rb'
# executed in alphabetical order. Longer names sort later.
# place in order from low to high level and easy pass to harder, so that first fail is likely the cause.
# move passing tests toward end
class StreamMethodTest < DefaultTestCase2
include DefaultTests2
include StreamMethod::Examples
def fossil_test_acq_and_rescue
	stream=acquisition_stream_specs(@testURL.to_sym)
	acq=HTTP_method.clone
	acq.interface_method
	assert(!acq.interaction.error.nil? || !acq.interaction.acquisition_data.empty?)
rescue  StandardError => exception_raised
	puts 'Error: ' + exception_raised.inspect + ' could not get data from '+stream.url
	puts "$!=#{$!}"
end #def	  
def test_gui_name
	acq=HTTP_method.clone
	assert_equal("@input", acq.gui_name('input'))
end #gui_name
def test_instance_name_reference
	acq=HTTP_method.clone
	assert_equal("self[:input]", acq.instance_name_reference('input'))
end #instance_name_reference
def test_default_method
	acq=HTTP_method.clone
	assert_equal('@acquisition=@uri', acq.default_method)
end #default_method
def test_map_io
	acq=HTTP_method.clone
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
def test_eval_method
	acq=HTTP_method.clone
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
	assert_include(acq.methods(true), :interface_code_method)
#	acq.eval_method(:interface_code,'')
	assert_include(acq.methods(true), :interface_code_rows)
	assert_include(acq.singleton_methods(true), :interface_code_rows)
	explain_assert_respond_to(acq,:interface_code_rows)
	assert_not_nil(acq.interface_code_rows)
end #eval_method
def test_compile_code
# test one case
	acq=HTTP_method.clone
	assert_instance_of(StreamMethod,acq)
#	puts "acq.matching_methods(/code/).inspect=#{acq.matching_methods(/code/).inspect}"
	acq.compile_code!
	assert_not_nil(acq)
	acq.assert_pre_conditions
# test all cases
	StreamMethod.all.each do |sm|
		assert_instance_of(StreamMethod,sm)
#		puts "sm.matching_methods(/code/).inspect=#{sm.matching_methods(/code/).inspect}"
		sm.compile_code!
		#~ if sm.self[:errorz]=self[:errorz].empty? then
			#~ puts "No error in sm=#{sm.interface_code.inspect}"
		#~ else
			#~ puts "sm.self[:errorz]=self[:errorz]=#{sm.self[:errorz]=self[:errorz].inspect} for sm=#{sm.interface_code.inspect}"
		#~ end #if
		assert_not_nil(sm)
		assert(!sm.respond_to?(:syntax_check_temp_method),"syntax_check_temp_method is a method of #{sm.canonicalName}.")
		assert_empty(sm.syntax_errors?)
		sm.assert_pre_conditions
	end #each_value
end #compile_code
def test_syntax_error
	sm=HTTP_method.clone
	sm.compile_code!
	assert_empty(sm.errors.keys)
	sm.assert_active_model_error

	sm=HTTP_method.clone # reinitialize from fixture
	sm.interface_code='***'
	sm.compile_code!
	expected_interface_error_message= %{SyntaxError: #<SyntaxError: (eval):4:in `eval_method': compile error\n(eval):3: syntax error, unexpected tPOW, expecting kEND>}
	expected_errors=ActiveModel::Errors.new(self)
	expected_errors.add(:interface_code, expected_interface_error_message)
	assert_equal(expected_errors, sm.errors)
	sm.assert_active_model_error(:rescue_code)
	sm.assert_active_model_error(:return_code)
	sm.assert_active_model_error(:interface_code, expected_interface_error_message.to_exact_regexp)
#	assert_equal(expected_errors, sm.errors)
	assert_equal([expected_interface_error_message], sm.errors[:interface_code],"interface_code=#{sm[:interface_code]}")
	assert_equal([expected_interface_error_message], sm.syntax_errors?)
# try different error
	sm=HTTP_method.clone # reinitialize from fixture
	sm.return_code='***'
	sm.compile_code!
#	assert_equal('***', sm.interface_code)
	sm.assert_active_model_error(:interface_code)
	sm.assert_active_model_error(:rescue_code)
	expected_return_error_message= %{SyntaxError: #<SyntaxError: (eval):3:in `eval_method': compile error\n(eval):2: syntax error, unexpected tPOW>}
	assert_instance_of(Array, sm.errors[:rescue_code],"rescue_code=#{sm[:rescue_code]}")
	sm.assert_active_model_error(:return_code, expected_return_error_message.to_exact_regexp)
# try third error
	sm=HTTP_method.clone # reinitialize from fixture
	sm.rescue_code='***'
	sm.compile_code!
#	assert_equal('***', sm.interface_code)
	sm.assert_active_model_error(:interface_code)
	sm.assert_active_model_error(:return_code)
	expected_rescue_error_message= %{SyntaxError: #<SyntaxError: (eval):4:in `eval_method': compile error\n(eval):2: syntax error, unexpected tPOW, expecting kTHEN or ':' or '\\n' or ';'\nrescue ***\n         ^>}
	assert_instance_of(Array, sm.errors[:rescue_code],"rescue_code=#{sm[:rescue_code]}")
	sm.assert_active_model_error(:rescue_code, expected_rescue_error_message.to_exact_regexp)
	assert_instance_of(String, sm.errors[:rescue_code][0],"rescue_code=#{sm[:rescue_code]}")
	assert_equal([expected_rescue_error_message], sm.errors[:rescue_code],"rescue_code=#{sm[:rescue_code]}")
# try multiple errors
	sm.interface_code='***'
	sm.compile_code!
	sm.assert_active_model_error(:return_code)
	sm.assert_active_model_error(:interface_code, expected_interface_error_message.to_exact_regexp)
	assert_instance_of(Array, sm.errors[:rescue_code],"rescue_code=#{sm[:rescue_code]}")
	sm.assert_active_model_error(:rescue_code, expected_rescue_error_message.to_exact_regexp)
# now check all stream_methods
	StreamMethod.all.each  do |sm|
		sm.compile_code!
#		assert_empty(sm.errors.keys)
		sm.assert_active_model_error
	end #each
end #syntax_error
def test_input_stream_names
	acq=HTTP_method.clone
	stream_pattern_arguments=acq.stream_pattern.stream_pattern_arguments
	stream_inputs=stream_pattern_arguments.select{|a| a.direction=='Input'}
	assert_equal(['URI'], stream_inputs.map{|a| a.name})
	assert_equal(['uri'], acq.input_stream_names)

end #input_stream_names
def test_output_stream_names
	acq=HTTP_method.clone
	stream_pattern_arguments=acq.stream_pattern.stream_pattern_arguments
	stream_outputs=stream_pattern_arguments.select{|a| a.direction=='Output'}
	assert_equal(['Acquisition'], stream_outputs.map{|a| a.name})
	assert_equal(['acquisition'], acq.output_stream_names)

end #output_stream_names
def fire_check(interface_code, interface_code_errors, acquisition_errors)
	stream_method=StreamMethod.new
	stream_method.assert_active_model_error(field, expected_error_message_regexp)
	stream_method.assert_field_firing_error
	stream_method[:interface_code]=interface_code
	assert_instance_of(StreamMethod,stream_method)
#	puts "stream_method.matching_methods(/code/).inspect=#{stream_method.matching_methods(/code/).inspect}"
	stream_method.compile_code!
	stream_method[:uri]=Url.find_by_name('Cable Modem')
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
def test_fire
	acq=HTTP_method.clone
	acq.assert_active_model_error # make sure there are no lingering (uninitialized) errors
	acq.compile_code!
	acq.assert_active_model_error # asume compilation errors have been all taken care of , earlier
	acq[:uri]=Url.find_by_name('Cable Modem')
	firing=acq.fire!
	acq.assert_active_model_error(:rescue_code)
	acq.assert_active_model_error(:return_code)
	expected_interface_error_message=%{#<NoMethodError: undefined method `uri' for #<Url:0xb5f22960>>}
#?	acq.assert_active_model_error(:interface_code, expected_interface_error_message.to_exact_regexp)
	fire_check(acq.interface_code, ['#<NoMethodError: undefined method `uri\' for "http://192.168.100.1":String>'], ['is empty.'])
	fire_check(acq.default_method, [], [])
	assert_equal("http://192.168.100.1", acq[:acquisition])
	@my_fixtures.each_pair do |key, sm|
		assert_instance_of(StreamMethod, sm)
		fire_check(sm.default_method, [], [])
	end #each
end #fire
def test_errors
	acq=HTTP_method.clone
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
