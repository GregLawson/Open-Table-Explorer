require 'test_helper'

class AcquisitionStreamSpecTest < ActiveSupport::TestCase
  # Replace this with your real tests.
   def test_nameFromInterface
    assert_equal('HTTP',acquisition_stream_specs(:one).nameFromInterface)
  end
   def test_nameFromInterface
    assert_equal('http',acquisition_stream_specs(:one).scheme)
  end
end
