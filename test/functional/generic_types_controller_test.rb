require 'test_helper'

class GenericTypesControllerTest < ActionController::TestCase
fixtures :generic_types
setup do
    @generic_type = generic_types(:one)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:generic_types)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_generic_type
    assert_difference('GenericType.count') do
	    generic_type_attributes=@generic_type.attributes
	    generic_type_attributes['data_regexp']='[test insertion with unique data_regexp]'
      post :create, :generic_type => generic_type_attributes
    end

    assert_redirected_to generic_type_path(assigns(:generic_type))
  end

def test_should_show_generic_type
    get :show, :id => @generic_type.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @generic_type.to_param
    assert_response :success
  end

def test_should_update_generic_type
    put :update, :id => @generic_type.to_param, :generic_type => @generic_type.attributes
    assert_redirected_to generic_type_path(assigns(:generic_type))
  end

def test_should_destroy_generic_type
    assert_difference('GenericType.count', -1) do
      delete :destroy, :id => @generic_type.to_param
    end

    assert_redirected_to generic_types_path
  end
end
