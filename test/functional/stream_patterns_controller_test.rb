require 'test_helper'

class StreamPatternsControllerTest < ActionController::TestCase
	fixtures :stream_patterns
  setup do
    @stream_pattern = stream_patterns(:Acquisition)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_patterns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stream_pattern" do
    assert_difference('StreamPattern.count') do
      post :create, :stream_pattern => @stream_pattern.attributes
    end

    assert_redirected_to stream_pattern_path(assigns(:stream_pattern))
  end

  test "should show stream_pattern" do
    get :show, :id => @stream_pattern.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @stream_pattern.to_param
    assert_response :success
  end

  test "should update stream_pattern" do
    put :update, :id => @stream_pattern.to_param, :stream_pattern => @stream_pattern.attributes
    assert_redirected_to stream_pattern_path(assigns(:stream_pattern))
  end

  test "should destroy stream_pattern" do
    assert_difference('StreamPattern.count', -1) do
      delete :destroy, :id => @stream_pattern.to_param
    end

    assert_redirected_to stream_patterns_path
  end
end
