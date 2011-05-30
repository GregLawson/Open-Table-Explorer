require 'test_helper'

class RubyInterfacesControllerTest < ActionController::TestCase
  setup do
    @ruby_interface = ruby_interfaces(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ruby_interfaces)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ruby_interface" do
    assert_difference('RubyInterface.count') do
      post :create, :ruby_interface => @ruby_interface.attributes
    end

    assert_redirected_to ruby_interface_path(assigns(:ruby_interface))
  end

  test "should show ruby_interface" do
    get :show, :id => @ruby_interface.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @ruby_interface.to_param
    assert_response :success
  end

  test "should update ruby_interface" do
    put :update, :id => @ruby_interface.to_param, :ruby_interface => @ruby_interface.attributes
    assert_redirected_to ruby_interface_path(assigns(:ruby_interface))
  end

  test "should destroy ruby_interface" do
    assert_difference('RubyInterface.count', -1) do
      delete :destroy, :id => @ruby_interface.to_param
    end

    assert_redirected_to ruby_interfaces_path
  end
end
