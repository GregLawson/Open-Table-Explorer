require 'test_helper'

class StreamMethodArgumentsControllerTest < ActionController::TestCase
	fixtures :stream_method_arguments
  setup do
    @stream_method_argument = stream_method_arguments(:URL)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_method_arguments)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_stream_method_argument
    assert_difference('StreamMethodArgument.count') do
      post :create, :stream_method_argument => @stream_method_argument.attributes
    end

    assert_redirected_to stream_method_argument_path(assigns(:stream_method_argument))
  end

def test_should_show_stream_method_argument
    get :show, :id => @stream_method_argument.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @stream_method_argument.to_param
    assert_response :success
  end

def test_should_update_stream_method_argument
    put :update, :id => @stream_method_argument.to_param, :stream_method_argument => @stream_method_argument.attributes
    assert_redirected_to stream_method_argument_path(assigns(:stream_method_argument))
  end

def test_should_destroy_stream_method_argument
    assert_difference('StreamMethodArgument.count', -1) do
      delete :destroy, :id => @stream_method_argument.to_param
    end

    assert_redirected_to stream_method_arguments_path
  end
end
