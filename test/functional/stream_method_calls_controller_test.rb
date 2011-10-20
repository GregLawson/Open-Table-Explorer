require 'test_helper'

class StreamMethodCallsControllerTest < ActionController::TestCase
	fixtures :stream_method_calls
  setup do
    @stream_method_call = stream_method_calls(:one)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_method_calls)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_stream_method_call
    assert_difference('StreamMethodCall.count') do
      post :create, :stream_method_call => @stream_method_call.attributes
    end

    assert_redirected_to stream_method_call_path(assigns(:stream_method_call))
  end

def test_should_show_stream_method_call
    get :show, :id => @stream_method_call.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @stream_method_call.to_param
    assert_response :success
  end

def test_should_update_stream_method_call
    put :update, :id => @stream_method_call.to_param, :stream_method_call => @stream_method_call.attributes
    assert_redirected_to stream_method_call_path(assigns(:stream_method_call))
  end

def test_should_destroy_stream_method_call
    assert_difference('StreamMethodCall.count', -1) do
      delete :destroy, :id => @stream_method_call.to_param
    end

    assert_redirected_to stream_method_calls_path
  end
end
