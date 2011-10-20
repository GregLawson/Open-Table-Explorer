require 'test_helper'

class StreamParametersControllerTest < ActionController::TestCase
	fixtures :stream_parameters
  setup do
    @stream_parameter = stream_parameters(:one)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_parameters)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_stream_parameter
    assert_difference('StreamParameter.count') do
      post :create, :stream_parameter => @stream_parameter.attributes
    end

    assert_redirected_to stream_parameter_path(assigns(:stream_parameter))
  end

def test_should_show_stream_parameter
    get :show, :id => @stream_parameter.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @stream_parameter.to_param
    assert_response :success
  end

def test_should_update_stream_parameter
    put :update, :id => @stream_parameter.to_param, :stream_parameter => @stream_parameter.attributes
    assert_redirected_to stream_parameter_path(assigns(:stream_parameter))
  end

def test_should_destroy_stream_parameter
    assert_difference('StreamParameter.count', -1) do
      delete :destroy, :id => @stream_parameter.to_param
    end

    assert_redirected_to stream_parameters_path
  end
end
