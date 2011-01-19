require 'test_helper'

class HuelseriesControllerTest < ActionController::TestCase
  setup do
    @huelseries = huelseries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:huelseries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create huelseries" do
    assert_difference('Huelserie.count') do
      post :create, :huelseries => @huelseries.attributes
    end

    assert_redirected_to huelseries_path(assigns(:huelseries))
  end

  test "should show huelseries" do
    get :show, :id => @huelseries.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @huelseries.to_param
    assert_response :success
  end

  test "should update huelseries" do
    put :update, :id => @huelseries.to_param, :huelseries => @huelseries.attributes
    assert_redirected_to huelseries_path(assigns(:huelseries))
  end

  test "should destroy huelseries" do
    assert_difference('Huelserie.count', -1) do
      delete :destroy, :id => @huelseries.to_param
    end

    assert_redirected_to huelseries_path
  end
end
