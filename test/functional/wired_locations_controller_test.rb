require 'test_helper'

class WiredLocationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:wired_locations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_wired_location
    assert_difference('WiredLocation.count') do
      post :create, :wired_location => { node +> 99999 }
    end

    assert_redirected_to wired_location_path(assigns(:wired_location))
  end

  def test_should_show_wired_location
    get :show, :id => wired_locations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => wired_locations(:one).id
    assert_response :success
  end

  def test_should_update_wired_location
    put :update, :id => wired_locations(:one).id, :wired_location => { }
    assert_redirected_to wired_location_path(assigns(:wired_location))
  end

  def test_should_destroy_wired_location
    assert_difference('WiredLocation.count', -1) do
      delete :destroy, :id => wired_locations(:one).id
    end

    assert_redirected_to wired_locations_path
  end
end
