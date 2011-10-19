require 'test_helper'

class OfxesControllerTest < ActionController::TestCase
	fixtures :ofxs
  setup do
    @ofx = ofxes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ofxes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ofx" do
    assert_difference('Ofx.count') do
      post :create, :ofx => @ofx.attributes
    end

    assert_redirected_to ofx_path(assigns(:ofx))
  end

  test "should show ofx" do
    get :show, :id => @ofx.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @ofx.to_param
    assert_response :success
  end

  test "should update ofx" do
    put :update, :id => @ofx.to_param, :ofx => @ofx.attributes
    assert_redirected_to ofx_path(assigns(:ofx))
  end

  test "should destroy ofx" do
    assert_difference('Ofx.count', -1) do
      delete :destroy, :id => @ofx.to_param
    end

    assert_redirected_to ofxes_path
  end
end
