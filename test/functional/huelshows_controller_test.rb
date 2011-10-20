require 'test_helper'

class HuelshowsControllerTest < ActionController::TestCase
	fixtures :huelshows
  setup do
    @huelshow = huelshows(:one)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:huelshows)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_huelshow
    assert_difference('Huelshow.count') do
	    huelshow_attributes=@huelshow.attributes
	    huelshow_attributes[:shortname]='test create record'
	    huelshow_attributes[:name]='test create record'
      post :create, :huelshow => huelshow_attributes
    end

    assert_redirected_to huelshow_path(assigns(:huelshow))
  end

def test_should_show_huelshow
    get :show, :id => @huelshow.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @huelshow.to_param
    assert_response :success
  end

def test_should_update_huelshow
    put :update, :id => @huelshow.to_param, :huelshow => @huelshow.attributes
    assert_redirected_to huelshow_path(assigns(:huelshow))
  end

def test_should_destroy_huelshow
    assert_difference('Huelshow.count', -1) do
      delete :destroy, :id => @huelshow.to_param
    end

    assert_redirected_to huelshows_path
  end
end
