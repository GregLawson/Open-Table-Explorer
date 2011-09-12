require 'test_helper'

class StreamMethodCallTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test 'EEG' do
    assert_equal([],StreamPattern.fnd_by_acquisition('File').inspect)
    assert_equal([],StreamPatternArgument.find_by_stream_pattern('Acquisition').inspect)
    assert_equal([],StreamMethodArgument.find_by_stream_pattern().inspect)
    assert_equal([],StreamMethod.first.inspect)
    assert_equal([],StreamMethodCall.first.inspect)
  end
end
