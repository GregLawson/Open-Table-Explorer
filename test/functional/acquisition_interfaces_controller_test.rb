require 'test_helper'

class AcquisitionInterfacesControllerTest < ActionController::TestCase
fixtures :acquisition_interfaces
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:acquisition_interfaces)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_acquisition_interface
    assert_difference('AcquisitionInterface.count') do
      post :create, :acquisition_interface => { }
    end

    assert_redirected_to acquisition_interface_path(assigns(:acquisition_interface))
  end

  def test_should_show_acquisition_interface
    get :show, :id => acquisition_interfaces(:HTTP).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => acquisition_interfaces(:HTTP).id
    assert_response :success
  end

  def test_should_update_acquisition_interface
    put :update, :id => acquisition_interfaces(:HTTP).id, :acquisition_interface => { }
    assert_redirected_to acquisition_interface_path(assigns(:acquisition_interface))
  end

  def test_should_destroy_acquisition_interface
    assert_difference('AcquisitionInterface.count', -1) do
      delete :destroy, :id => acquisition_interfaces(:HTTP).id
    end

    assert_redirected_to acquisition_interfaces_path
  end
end
