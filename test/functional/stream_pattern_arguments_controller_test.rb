require 'test_helper'

class StreamPatternArgumentsControllerTest < ActionController::TestCase
	fixtures :stream_pattern_arguments
  setup do
    @stream_pattern_argument = stream_pattern_arguments(:URI)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_pattern_arguments)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_stream_pattern_argument
    assert_difference('StreamPatternArgument.count') do
      post :create, :stream_pattern_argument => @stream_pattern_argument.attributes
    end

    assert_redirected_to stream_pattern_argument_path(assigns(:stream_pattern_argument))
  end

def test_should_show_stream_pattern_argument
    get :show, :id => @stream_pattern_argument.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @stream_pattern_argument.to_param
    assert_response :success
  end

def test_should_update_stream_pattern_argument
    put :update, :id => @stream_pattern_argument.to_param, :stream_pattern_argument => @stream_pattern_argument.attributes
    assert_redirected_to stream_pattern_argument_path(assigns(:stream_pattern_argument))
  end

def test_should_destroy_stream_pattern_argument
    assert_difference('StreamPatternArgument.count', -1) do
      delete :destroy, :id => @stream_pattern_argument.to_param
    end

    assert_redirected_to stream_pattern_arguments_path
  end
end
