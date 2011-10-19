require 'test_helper'

class StreamPatternArgumentsControllerTest < ActionController::TestCase
	fixtures :stream_pattern_arguments
  setup do
    @stream_pattern_argument = stream_pattern_arguments(:URI)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_pattern_arguments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stream_pattern_argument" do
    assert_difference('StreamPatternArgument.count') do
      post :create, :stream_pattern_argument => @stream_pattern_argument.attributes
    end

    assert_redirected_to stream_pattern_argument_path(assigns(:stream_pattern_argument))
  end

  test "should show stream_pattern_argument" do
    get :show, :id => @stream_pattern_argument.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @stream_pattern_argument.to_param
    assert_response :success
  end

  test "should update stream_pattern_argument" do
    put :update, :id => @stream_pattern_argument.to_param, :stream_pattern_argument => @stream_pattern_argument.attributes
    assert_redirected_to stream_pattern_argument_path(assigns(:stream_pattern_argument))
  end

  test "should destroy stream_pattern_argument" do
    assert_difference('StreamPatternArgument.count', -1) do
      delete :destroy, :id => @stream_pattern_argument.to_param
    end

    assert_redirected_to stream_pattern_arguments_path
  end
end
