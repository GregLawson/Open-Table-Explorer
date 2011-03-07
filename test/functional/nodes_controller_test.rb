require 'test_helper'

class NodesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:nodes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_node
    assert_difference('Node.count') do
      post :create, :node => { }
    end

    assert_redirected_to node_path(assigns(:node))
  end

  def test_should_show_node
    get :show, :id => nodes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => nodes(:one).id
    assert_response :success
  end

  def test_should_update_node
    put :update, :id => nodes(:one).id, :node => { }
    assert_redirected_to node_path(assigns(:node))
  end

  def test_should_destroy_node
    assert_difference('Node.count', -1) do
      delete :destroy, :id => nodes(:one).id
    end

    assert_redirected_to nodes_path
  end
end
