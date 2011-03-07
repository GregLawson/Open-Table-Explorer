require 'test_helper'

class EdisonsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:edisons)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_edison
    assert_difference('Edison.count') do
      post :create, :edison => { }
    end

    assert_redirected_to edison_path(assigns(:edison))
  end

  def test_should_show_edison
    get :show, :id => edisons(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => edisons(:one).id
    assert_response :success
  end

  def test_should_update_edison
    put :update, :id => edisons(:one).id, :edison => { }
    assert_redirected_to edison_path(assigns(:edison))
  end

  def test_should_destroy_edison
    assert_difference('Edison.count', -1) do
      delete :destroy, :id => edisons(:one).id
    end

    assert_redirected_to edisons_path
  end
end
