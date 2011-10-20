require 'test_helper'

class ErrorTypesControllerTest < ActionController::TestCase
 fixtures :error_types
  setup do
    @error_type = error_types(:one)
  end

def test_should_get index
    get :index
    assert_response :success
    assert_not_nil assigns(:error_types)
  end

def test_should_get new
    get :new
    assert_response :success
  end

def test_should_create error_type
    assert_difference('ErrorType.count') do
      post :create, :error_type => @error_type.attributes
    end

    assert_redirected_to error_type_path(assigns(:error_type))
  end

def test_should_show error_type
    get :show, :id => @error_type.to_param
    assert_response :success
  end

def test_should_get edit
    get :edit, :id => @error_type.to_param
    assert_response :success
  end

def test_should_update error_type
    put :update, :id => @error_type.to_param, :error_type => @error_type.attributes
    assert_redirected_to error_type_path(assigns(:error_type))
  end

def test_should_destroy error_type
    assert_difference('ErrorType.count', -1) do
      delete :destroy, :id => @error_type.to_param
    end

    assert_redirected_to error_types_path
  end
end
