###########################################################################
#    Copyright (C) 2011-2013 by Greg Lawson                                      
#    <GregLawson123@gmail.com>                                                             
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
require_relative 'test_environment'
require_relative 'default_test_case.rb'
require_relative '../../app/models/url.rb'
class UrlTest < DefaultTestCase2
include DefaultTests2
@@test_url_record=Url.find_by_name('nmap_local_network_0')
def test_find_by_name
 	assert_equal('EEG', Url.find_by_name('EEG').href)
end #find_by_name
def test_parsedURI
end #def
def test_schemelessUrl
 	assert_equal('/home/greg/Desktop/Downloads/emotive/qdot-emokit-2fa5e40/python/logfile.txt', Url.find_by_name('EEG').schemelessUrl)
end #schemelessUrl
def test_uriComponent
end #end
def test_uriArray
end #def
def test_uriHash
end #def
def test_scheme
	assert_equal('shell', @@test_url_record.scheme)
end #scheme
def test_stream_method
	scheme_name=@@test_url_record.scheme
	scheme_name=scheme_name[0..0].upcase+scheme_name[1..-1]
	assert_equal('Shell', scheme_name)
	stream_method= StreamMethod.find_by_name(scheme_name)
	assert_not_nil(@@test_url_record.stream_method)
end #stream_method
def implicit_stream_link
end #implicit_stream_link
def setup
	@testURL='http://192.168.3.193/api/LiveData.xml'
#	assert_module_included(model_class?,Generic_Table)
	explain_assert_respond_to(model_class?,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
	assert_respond_to(model_class?,:sequential_id?,"#{@model_name}.rb probably does not include include Generic_Table statement.")
#	define_association_names #38271 associations
end #stream_method
def test_id_equal
	assert(!model_class?.sequential_id?, "model_class?=#{model_class?}, should not be a sequential_id.")
#	assert_test_id_equal
end #test_id_equal
end #Url
