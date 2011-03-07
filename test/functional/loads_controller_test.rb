require 'test_helper'

class LoadsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:loads)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_loads
    assert_difference('Load.count') do
      post :create, :loads => { node=>9999999  }
    end

    assert_redirected_to loads_path(assigns(:loads))
  end

  def test_should_show_loads
    get :show, :id => loads(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => loads(:one).id
    assert_response :success
  end

  def test_should_update_loads
    put :update, :id => loads(:one).id, :loads => { }
    assert_redirected_to loads_path(assigns(:loads))
  end

  def test_should_destroy_loads
    assert_difference('Load.count', -1) do
      delete :destroy, :id => loads(:one).id
    end

    assert_redirected_to loads_path
  end
end
