require 'test_helper'

class StreamMethodArgumentsControllerTest < ActionController::TestCase
  setup do
    @stream_method_argument = stream_method_arguments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_method_arguments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stream_method_argument" do
    assert_difference('StreamMethodArgument.count') do
      post :create, :stream_method_argument => @stream_method_argument.attributes
    end

    assert_redirected_to stream_method_argument_path(assigns(:stream_method_argument))
  end

  test "should show stream_method_argument" do
    get :show, :id => @stream_method_argument.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @stream_method_argument.to_param
    assert_response :success
  end

  test "should update stream_method_argument" do
    put :update, :id => @stream_method_argument.to_param, :stream_method_argument => @stream_method_argument.attributes
    assert_redirected_to stream_method_argument_path(assigns(:stream_method_argument))
  end

  test "should destroy stream_method_argument" do
    assert_difference('StreamMethodArgument.count', -1) do
      delete :destroy, :id => @stream_method_argument.to_param
    end

    assert_redirected_to stream_method_arguments_path
  end
end
