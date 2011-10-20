require 'test_helper'

class StreamPatternsControllerTest < ActionController::TestCase
	fixtures :stream_patterns
  setup do
    @stream_pattern = stream_patterns(:Acquisition)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_patterns)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_stream_pattern
    assert_difference('StreamPattern.count') do
      post :create, :stream_pattern => @stream_pattern.attributes
    end

    assert_redirected_to stream_pattern_path(assigns(:stream_pattern))
  end

def test_should_show_stream_pattern
    get :show, :id => @stream_pattern.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @stream_pattern.to_param
    assert_response :success
  end

def test_should_update_stream_pattern
    put :update, :id => @stream_pattern.to_param, :stream_pattern => @stream_pattern.attributes
    assert_redirected_to stream_pattern_path(assigns(:stream_pattern))
  end

def test_should_destroy_stream_pattern
    assert_difference('StreamPattern.count', -1) do
      delete :destroy, :id => @stream_pattern.to_param
    end

    assert_redirected_to stream_patterns_path
  end
end
