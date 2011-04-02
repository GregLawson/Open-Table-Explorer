require 'test_helper'

class HostsControllerTest < ActionController::TestCase
 def setup
    @host = hosts(:one)
 end
 def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:hosts)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_host
    assert_difference('Host.count') do
	    host_attributes=@host.attributes
	    host_attributes[:ip]='255.255.255.255'
      post :create, :host => host_attributes
    end

    assert_redirected_to host_path(assigns(:host))
  end

  def test_should_show_host
    get :show, :id => hosts(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => hosts(:one).id
    assert_response :success
  end

  def test_should_update_host
    put :update, :id => hosts(:one).id, :host => { }
    assert_redirected_to host_path(assigns(:host))
  end

  def test_should_destroy_host
    assert_difference('Host.count', -1) do
      delete :destroy, :id => hosts(:one).id
    end

    assert_redirected_to hosts_path
  end
end
