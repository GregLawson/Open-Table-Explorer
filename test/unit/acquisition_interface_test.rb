require 'test_helper'

class AcquisitionInterfaceTest < ActiveSupport::TestCase
def test_scheme
	testAnswer(acquisition_interfaces(:one),:scheme,'http')
end #test
  def test_acquisition_class_name
	  testAnswer(acquisition_interfaces(:one),:acquisition_class_name,'HTTP_Acquisition')
  end #test
end
