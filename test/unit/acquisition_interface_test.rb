require 'test_helper'

class AcquisitionInterfaceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
def test_scheme
	testCall(acquisition_interfaces(:one),:scheme)
	testAnswer(acquisition_interfaces(:one),:scheme,'http')
end #test
  def test_nameFromInterface
    assert_equal('http',acquisition_interfaces(:one).scheme)
  end
  def test_acquisition_class_name
	  assert_equal('HTTP_Acquisition',acquisition_interfaces(:one).acquisition_class_name)
  end #test
end
