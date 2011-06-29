require 'test_helper'

class StreamMethodsControllerTest < ActionController::TestCase
  setup do
    @stream_method = stream_methods(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_methods)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stream_method" do
    assert_difference('StreamMethod.count') do
      post :create, :stream_method => @stream_method.attributes
    end

    assert_redirected_to stream_method_path(assigns(:stream_method))
  end

  test "should show stream_method" do
    get :show, :id => @stream_method.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @stream_method.to_param
    assert_response :success
  end

  test "should update stream_method" do
    put :update, :id => @stream_method.to_param, :stream_method => @stream_method.attributes
    assert_redirected_to stream_method_path(assigns(:stream_method))
  end

  test "should destroy stream_method" do
    assert_difference('StreamMethod.count', -1) do
      delete :destroy, :id => @stream_method.to_param
    end

    assert_redirected_to stream_methods_path
  end
end
