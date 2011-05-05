require 'test_helper'

class TransfersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:transfers)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_transfer
    assert_difference('Transfer.count') do
      post :create, :transfer => { }
    end

    assert_redirected_to transfer_path(assigns(:transfer))
  end

  def test_should_show_transfer
    get :show, :id => fixtures('transfers')[1].id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => fixtures('transfers')[1].id
    assert_response :success
  end

  def test_should_update_transfer
    put :update, :id => fixtures('transfers')[1].id, :transfer => { }
    assert_redirected_to transfer_path(assigns(:transfer))
  end

  def test_should_destroy_transfer
    assert_difference('Transfer.count', -1) do
      delete :destroy, :id => fixtures('transfers')[1].id
    end

    assert_redirected_to transfers_path
  end
end
