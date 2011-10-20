require 'test_helper'

class ScalarArgumentsControllerTest < ActionController::TestCase
	fixtures :scalar_arguments
  setup do
    @scalar_argument = scalar_arguments(:one)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:scalar_arguments)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_scalar_argument
    assert_difference('ScalarArgument.count') do
      post :create, :scalar_argument => @scalar_argument.attributes
    end

    assert_redirected_to scalar_argument_path(assigns(:scalar_argument))
  end

def test_should_show_scalar_argument
    get :show, :id => @scalar_argument.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @scalar_argument.to_param
    assert_response :success
  end

def test_should_update_scalar_argument
    put :update, :id => @scalar_argument.to_param, :scalar_argument => @scalar_argument.attributes
    assert_redirected_to scalar_argument_path(assigns(:scalar_argument))
  end

def test_should_destroy_scalar_argument
    assert_difference('ScalarArgument.count', -1) do
      delete :destroy, :id => @scalar_argument.to_param
    end

    assert_redirected_to scalar_arguments_path
  end
end
