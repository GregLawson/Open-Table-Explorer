require 'test_helper'

class ExampleTypesControllerTest < ActionController::TestCase
fixtures :example_types
  def setup
    @example_type = example_types(:one)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:example_types)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_example_type
    assert_difference('ExampleType.count') do
	    example_type_attributes=@example_type.attributes
	    example_type_attributes['example_string']='123456.789'
	    example_type_attributes['import_class']='test insertion'
      post :create, :example_type => example_type_attributes
    end

    assert_redirected_to example_type_path(assigns(:example_type))
  end

def test_should_show_example_type
    get :show, :id => @example_type.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @example_type.to_param
    assert_response :success
  end

def test_should_update_example_type
    put :update, :id => @example_type.to_param, :example_type => @example_type.attributes
    assert_redirected_to example_type_path(assigns(:example_type))
  end

def test_should_destroy_example_type
    assert_difference('ExampleType.count', -1) do
      delete :destroy, :id => @example_type.to_param
    end

    assert_redirected_to example_types_path
  end
end
