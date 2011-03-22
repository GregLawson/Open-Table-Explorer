require 'test_helper'

class AcquisitionInterfaceTest < ActiveSupport::TestCase
def test_scheme
	testAnswer(acquisition_interfaces(:HTTP),:scheme,'http')
end #test
def test_acquisition_class_name
	  testAnswer(acquisition_interfaces(:HTTP),:acquisition_class_name,'HTTP_Acquisition')
end #test
def test_id_equal
		assert_equal(acquisition_interfaces(:HTTP).id,Fixtures::identify(:HTTP),"id != Fixtures::identify(:one)")
end #def
def test_id_equal
		assert_equal(acquisition_interfaces(:HTTP).id,acquisition_stream_specs('http://www.weather.gov/xml/current_obs/KLAX.xml'.to_sym).acquisition_interface_id,"id != acquisition_stream_spec_id")
end #def	  
end
