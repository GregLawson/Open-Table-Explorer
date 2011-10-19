require 'test_helper'

class ProductionFtpsControllerTest < ActionController::TestCase
	fixtures :production_ftps
  setup do
    @production_ftp = production_ftps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:production_ftps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create production_ftp" do
    assert_difference('ProductionFtp.count') do
      post :create, :production_ftp => @production_ftp.attributes
    end

    assert_redirected_to production_ftp_path(assigns(:production_ftp))
  end

  test "should show production_ftp" do
    get :show, :id => @production_ftp.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @production_ftp.to_param
    assert_response :success
  end

  test "should update production_ftp" do
    put :update, :id => @production_ftp.to_param, :production_ftp => @production_ftp.attributes
    assert_redirected_to production_ftp_path(assigns(:production_ftp))
  end

  test "should destroy production_ftp" do
    assert_difference('ProductionFtp.count', -1) do
      delete :destroy, :id => @production_ftp.to_param
    end

    assert_redirected_to production_ftps_path
  end
end
