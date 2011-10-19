require 'test_helper'

class StreamMethodCallsControllerTest < ActionController::TestCase
	fixtures :stream_method_calls
  setup do
    @stream_method_call = stream_method_calls(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_method_calls)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stream_method_call" do
    assert_difference('StreamMethodCall.count') do
      post :create, :stream_method_call => @stream_method_call.attributes
    end

    assert_redirected_to stream_method_call_path(assigns(:stream_method_call))
  end

  test "should show stream_method_call" do
    get :show, :id => @stream_method_call.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @stream_method_call.to_param
    assert_response :success
  end

  test "should update stream_method_call" do
    put :update, :id => @stream_method_call.to_param, :stream_method_call => @stream_method_call.attributes
    assert_redirected_to stream_method_call_path(assigns(:stream_method_call))
  end

  test "should destroy stream_method_call" do
    assert_difference('StreamMethodCall.count', -1) do
      delete :destroy, :id => @stream_method_call.to_param
    end

    assert_redirected_to stream_method_calls_path
  end
end
