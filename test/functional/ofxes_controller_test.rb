require 'test_helper'

class OfxesControllerTest < ActionController::TestCase
	fixtures :ofxs
  setup do
    @ofx = ofxes(:one)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:ofxes)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_ofx
    assert_difference('Ofx.count') do
      post :create, :ofx => @ofx.attributes
    end

    assert_redirected_to ofx_path(assigns(:ofx))
  end

def test_should_show_ofx
    get :show, :id => @ofx.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @ofx.to_param
    assert_response :success
  end

def test_should_update_ofx
    put :update, :id => @ofx.to_param, :ofx => @ofx.attributes
    assert_redirected_to ofx_path(assigns(:ofx))
  end

def test_should_destroy_ofx
    assert_difference('Ofx.count', -1) do
      delete :destroy, :id => @ofx.to_param
    end

    assert_redirected_to ofxes_path
  end
end
