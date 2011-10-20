require 'test_helper'

class ProductionFtpsControllerTest < ActionController::TestCase
	fixtures :production_ftps
  setup do
    @production_ftp = production_ftps(:one)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:production_ftps)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_production_ftp
    assert_difference('ProductionFtp.count') do
      post :create, :production_ftp => @production_ftp.attributes
    end

    assert_redirected_to production_ftp_path(assigns(:production_ftp))
  end

def test_should_show_production_ftp
    get :show, :id => @production_ftp.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @production_ftp.to_param
    assert_response :success
  end

def test_should_update_production_ftp
    put :update, :id => @production_ftp.to_param, :production_ftp => @production_ftp.attributes
    assert_redirected_to production_ftp_path(assigns(:production_ftp))
  end

def test_should_destroy_production_ftp
    assert_difference('ProductionFtp.count', -1) do
      delete :destroy, :id => @production_ftp.to_param
    end

    assert_redirected_to production_ftps_path
  end
end
