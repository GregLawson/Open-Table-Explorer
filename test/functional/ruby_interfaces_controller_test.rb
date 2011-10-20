require 'test_helper'

class RubyInterfacesControllerTest < ActionController::TestCase
	fixtures :ruby_interfaces
  setup do
    @ruby_interface = ruby_interfaces(:HTTP)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:ruby_interfaces)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_ruby_interface
    assert_difference('RubyInterface.count') do
      post :create, :ruby_interface => @ruby_interface.attributes
    end

    assert_redirected_to ruby_interface_path(assigns(:ruby_interface))
  end

def test_should_show_ruby_interface
    get :show, :id => @ruby_interface.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @ruby_interface.to_param
    assert_response :success
  end

def test_should_update_ruby_interface
    put :update, :id => @ruby_interface.to_param, :ruby_interface => @ruby_interface.attributes
    assert_redirected_to acquisition_interface_path(assigns(:ruby_interface))
  end

def test_should_destroy_ruby_interface
    assert_difference('RubyInterface.count', -1) do
      delete :destroy, :id => @ruby_interface.to_param
    end

    assert_redirected_to ruby_interfaces_path
  end
end
