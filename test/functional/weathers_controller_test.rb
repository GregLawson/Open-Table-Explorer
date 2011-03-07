require 'test_helper'

class WeathersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:weathers)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_weather
    assert_difference('Weather.count') do
      post :create, :weather => { }
    end

    assert_redirected_to weather_path(assigns(:weather))
  end

  def test_should_show_weather
    get :show, :id => weathers(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => weathers(:one).id
    assert_response :success
  end

  def test_should_update_weather
    put :update, :id => weathers(:one).id, :weather => { }
    assert_redirected_to weather_path(assigns(:weather))
  end

  def test_should_destroy_weather
    assert_difference('Weather.count', -1) do
      delete :destroy, :id => weathers(:one).id
    end

    assert_redirected_to weathers_path
  end
end
