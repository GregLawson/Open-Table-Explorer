require 'test_helper'

class RoutersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:routers)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_router
    assert_difference('Router.count') do
      post :create, :router => { }
    end

    assert_redirected_to router_path(assigns(:router))
  end

  def test_should_show_router
    get :show, :id => routers(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => routers(:one).id
    assert_response :success
  end

  def test_should_update_router
    put :update, :id => routers(:one).id, :router => { }
    assert_redirected_to router_path(assigns(:router))
  end

  def test_should_destroy_router
    assert_difference('Router.count', -1) do
      delete :destroy, :id => routers(:one).id
    end

    assert_redirected_to routers_path
  end
end
