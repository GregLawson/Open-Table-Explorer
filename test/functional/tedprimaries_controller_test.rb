require 'test_helper'

class TedprimariesControllerTest < ActionController::TestCase
	fixtures :tedprimaries
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:tedprimaries)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_tedprimary
    assert_difference('Tedprimary.count') do
      post :create, :tedprimary => { }
    end

    assert_redirected_to tedprimary_path(assigns(:tedprimary))
  end

  def test_should_show_tedprimary
    get :show, :id => tedprimaries(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => tedprimaries(:one).id
    assert_response :success
  end

  def test_should_update_tedprimary
    put :update, :id => tedprimaries(:one).id, :tedprimary => { }
    assert_redirected_to tedprimary_path(assigns(:tedprimary))
  end

  def test_should_destroy_tedprimary
    assert_difference('Tedprimary.count', -1) do
      delete :destroy, :id => tedprimaries(:one).id
    end

    assert_redirected_to tedprimaries_path
  end
end
