require 'test_helper'

class HuelseriesControllerTest < ActionController::TestCase
fixtures :huelseries
setup do
@huelseries= huelseries(:one)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:huelseries)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_huelseries
    assert_difference('Huelserie.count') do
	    huelseries_attributes=@huelseries.attributes
	    huelseries_attributes['shortname']='test create'
      post :create, :huelseries => huelseries_attributes
    end

    assert_redirected_to huelseries_path(assigns(:huelseries))
  end

def test_should_show_huelseries
    get :show, :id => @huelseries.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @huelseries.to_param
    assert_response :success
  end

def test_should_update_huelseries
    put :update, :id => @huelseries.to_param, :huelseries => @huelseries.attributes
    assert_redirected_to huelseries_path(assigns(:huelseries))
  end

def test_should_destroy_huelseries
    assert_difference('Huelserie.count', -1) do
      delete :destroy, :id => @huelseries.to_param
    end

    assert_redirected_to huelseries_path
  end
end
