###########################################################################
#    Copyright (C) 2011-2017 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
#require_relative 'test_environment'
require_relative '../../app/models/unit.rb'
require_relative '../../app/models/test_environment_test_unit.rb'
require_relative '../../app/models/acquisition.rb'
class AcquisitionTest < TestCase
  module Examples # usually constant objects of the type (easy to understand (perhaps impractical) examples for testing)
#    include DefinitionalConstants
		Ruby_source_regexp = (/\s/.capture(:indent)).optional * /[\w\s]*/.capture(:code) * (/\#/ * /[\w\s]*/.capture(:comment)).optional
    Acquisition_test_file = Acquisition.new(uri_string: 'file:' + $PROGRAM_NAME, generic_type: Ruby_source_regexp)
  end # Examples
	include Examples
	
		def test_Acquisition_to_hash
			
		end # to_hash

		def test_Acquisition_open
			uri_string = 'file://' + File.expand_path($PROGRAM_NAME)
			uri_parse = UriParse.new(initialization_string: uri_string)
			refute_nil(uri_parse.uri)
			refute_nil(uri_parse.uri.open, uri_parse.uri.inspect)
			opened = if uri_parse.uri.respond_to?(:open)
				Kernel.open(uri_parse.uri)
			else
			end # if
			assert_equal(opened.read, Acquisition.open(uri_string).read)
			uri_string = 'http://www.google.com'
			uri_parse = UriParse.new(initialization_string: uri_string)
			acquisition_open = Acquisition.open(uri_string)
			refute_nil(acquisition_open, uri_parse.uri.inspect)
			if acquisition_open.instance_of?(Hash)
				assert_instance_of(Hash, acquisition_open)
				assert_kind_of(Exception, acquisition_open[:exception_object])
			else
			end # if

			uri_string = 'file://www.google.com'
			uri_parse = UriParse.new(initialization_string: uri_string)
			acquisition_open = Acquisition.open(uri_string)
			refute_nil(acquisition_open, uri_parse.uri.inspect)
			if acquisition_open.instance_of?(Hash)
				assert_instance_of(Hash, acquisition_open)
				assert_kind_of(Exception, acquisition_open[:exception_object])
			else
			end # if
		end # open
				
		def test_Acquisition_state
			uri_string = 'file://www.google.com'
			acquisition_open = Acquisition.open(uri_string)
			if acquisition_open.instance_of?(Hash)
				{acquisition_open: acquisition_open}
			else
				acquisition_string = acquisition_open.read
				capture = acquisition_string.capture?(generic_type)
				{acquisition_open: acquisition_open, acquisition_string: acquisition_string, capture: capture}
			end # if
			acquisition_state = Acquisition.state(uri_string, /google/)
			acquisition_object = Acquisition.new(uri_string: uri_string, generic_type: /google/)
#backtrace_differences?			assert_equal(acquisition_state.to_s, acquisition_object.state.to_s)
		end # state
		
	def test_DefinitionalConstants
	end # DefinitionalConstants

	def test_Acquisition_virtus
		assert_instance_of(String, Acquisition_test_file.uri_string, Acquisition_test_file.inspect)
		assert_instance_of(Regexp, Acquisition_test_file.generic_type, Acquisition_test_file.inspect)
		assert_nil(Acquisition_test_file.cached_acquisition_state, Acquisition_test_file.inspect)
		assert_equal(nil, Acquisition_test_file.cached_capture, Acquisition_test_file.inspect)
	end # values	

	def test_uri_parse
		assert_instance_of(UriParse, Acquisition_test_file.uri_parse, Acquisition_test_file.inspect)
		assert_equal('file', Acquisition_test_file.uri_parse.uri.scheme, Acquisition_test_file.inspect)
	end # uri_parse

	def test_uri
		assert_instance_of(URI::FILE, Acquisition_test_file.uri, Acquisition_test_file.inspect)
	end # uri_parse
	
	def test_acquire!
		assert_instance_of(String, Acquisition_test_file.acquire!, Acquisition_test_file.inspect)
		refute_nil(Acquisition_test_file.cached_acquisition_state[:acquisition_string], Acquisition_test_file.inspect)
		assert_instance_of(String, Acquisition_test_file.cached_acquisition_state[:acquisition_string], Acquisition_test_file.inspect)
		refute_nil(Acquisition_test_file.cached_acquisition_state, Acquisition_test_file.inspect)
#unnamed_capture?		refute_equal({}, Acquisition_test_file.cached_capture, Acquisition_test_file.inspect)
	end # acquire!
	
	def test_to_hash
		assert_includes(Acquisition_test_file.instance_variables, :@cached_acquisition_state, Acquisition_test_file.inspect)
		refute_nil(Acquisition_test_file.uri, Acquisition_test_file.inspect)
		refute_nil(Acquisition_test_file.generic_type, Acquisition_test_file.inspect)
		assert_equal(nil, Acquisition_test_file.cached_capture, Acquisition_test_file.inspect)
		capture = Acquisition_test_file.state[:acquisition_string].capture?(Acquisition_test_file.generic_type)
		assert_equal({:code=>"", :comment=>"", :indent=>nil}, Acquisition_test_file.to_hash, Acquisition_test_file.inspect)
	end # to_hash

	def test_state
	end # state
end # Acquisition
