require 'test_helper'

class ProductionsControllerTest < ActionController::TestCase
	fixtures :productions
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:productions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_production
    assert_difference('Production.count') do
      post :create, :production => { }
    end

    assert_redirected_to production_path(assigns(:production))
  end

  def test_should_show_production
    get :show, :id => productions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => productions(:one).id
    assert_response :success
  end

  def test_should_update_production
    put :update, :id => productions(:one).id, :production => { }
    assert_redirected_to production_path(assigns(:production))
  end

  def test_should_destroy_production
    assert_difference('Production.count', -1) do
      delete :destroy, :id => productions(:one).id
    end

    assert_redirected_to productions_path
  end
end
