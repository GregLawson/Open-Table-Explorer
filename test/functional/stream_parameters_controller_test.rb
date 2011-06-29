require 'test_helper'

class StreamParametersControllerTest < ActionController::TestCase
  setup do
    @stream_parameter = stream_parameters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_parameters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stream_parameter" do
    assert_difference('StreamParameter.count') do
      post :create, :stream_parameter => @stream_parameter.attributes
    end

    assert_redirected_to stream_parameter_path(assigns(:stream_parameter))
  end

  test "should show stream_parameter" do
    get :show, :id => @stream_parameter.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @stream_parameter.to_param
    assert_response :success
  end

  test "should update stream_parameter" do
    put :update, :id => @stream_parameter.to_param, :stream_parameter => @stream_parameter.attributes
    assert_redirected_to stream_parameter_path(assigns(:stream_parameter))
  end

  test "should destroy stream_parameter" do
    assert_difference('StreamParameter.count', -1) do
      delete :destroy, :id => @stream_parameter.to_param
    end

    assert_redirected_to stream_parameters_path
  end
end
