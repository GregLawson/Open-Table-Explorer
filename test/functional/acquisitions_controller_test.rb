require 'test_helper'

class AcquisitionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:acquisitions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_acquisition
    assert_difference('Acquisition.count') do
      post :create, :acquisition => { }
    end

    assert_redirected_to acquisition_path(assigns(:acquisition))
  end

  def test_should_show_acquisition
    get :show, :id => acquisitions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => acquisitions(:one).id
    assert_response :success
  end

  def test_should_update_acquisition
    put :update, :id => acquisitions(:one).id, :acquisition => { }
    assert_redirected_to acquisition_path(assigns(:acquisition))
  end

  def test_should_destroy_acquisition
    assert_difference('Acquisition.count', -1) do
      delete :destroy, :id => acquisitions(:one).id
    end

    assert_redirected_to acquisitions_path
  end
end
