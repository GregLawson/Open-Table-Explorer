require 'test_helper'

class ExampleTypesControllerTest < ActionController::TestCase
fixtures :example_types
  def setup
    @example_type = example_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:example_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create example_type" do
    assert_difference('ExampleType.count') do
	    example_type_attributes=@example_type.attributes
	    example_type_attributes['example_string']='123456.789'
	    example_type_attributes['import_class']='test insertion'
      post :create, :example_type => example_type_attributes
    end

    assert_redirected_to example_type_path(assigns(:example_type))
  end

  test "should show example_type" do
    get :show, :id => @example_type.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @example_type.to_param
    assert_response :success
  end

  test "should update example_type" do
    put :update, :id => @example_type.to_param, :example_type => @example_type.attributes
    assert_redirected_to example_type_path(assigns(:example_type))
  end

  test "should destroy example_type" do
    assert_difference('ExampleType.count', -1) do
      delete :destroy, :id => @example_type.to_param
    end

    assert_redirected_to example_types_path
  end
end
