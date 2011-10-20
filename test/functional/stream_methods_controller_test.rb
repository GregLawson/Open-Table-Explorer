require 'test_helper'

class StreamMethodsControllerTest < ActionController::TestCase
fixtures :stream_methods
  setup do
    @stream_method = stream_methods(:HTTP)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_methods)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_stream_method
    assert_difference('StreamMethod.count') do
      post :create, :stream_method => @stream_method.attributes
    end

    assert_redirected_to stream_method_path(assigns(:stream_method))
  end

def test_should_show_stream_method
    get :show, :id => @stream_method.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @stream_method.to_param
    assert_response :success
  end

def test_should_update_stream_method
    put :update, :id => @stream_method.to_param, :stream_method => @stream_method.attributes
    assert_redirected_to stream_method_path(assigns(:stream_method))
  end

def test_should_destroy_stream_method
    assert_difference('StreamMethod.count', -1) do
      delete :destroy, :id => @stream_method.to_param
    end

    assert_redirected_to stream_methods_path
  end
end
