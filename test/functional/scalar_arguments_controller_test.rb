require 'test_helper'

class ScalarArgumentsControllerTest < ActionController::TestCase
  setup do
    @scalar_argument = scalar_arguments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scalar_arguments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scalar_argument" do
    assert_difference('ScalarArgument.count') do
      post :create, :scalar_argument => @scalar_argument.attributes
    end

    assert_redirected_to scalar_argument_path(assigns(:scalar_argument))
  end

  test "should show scalar_argument" do
    get :show, :id => @scalar_argument.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @scalar_argument.to_param
    assert_response :success
  end

  test "should update scalar_argument" do
    put :update, :id => @scalar_argument.to_param, :scalar_argument => @scalar_argument.attributes
    assert_redirected_to scalar_argument_path(assigns(:scalar_argument))
  end

  test "should destroy scalar_argument" do
    assert_difference('ScalarArgument.count', -1) do
      delete :destroy, :id => @scalar_argument.to_param
    end

    assert_redirected_to scalar_arguments_path
  end
end
