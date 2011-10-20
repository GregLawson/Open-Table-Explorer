require 'test_helper'

class StreamLinksControllerTest < ActionController::TestCase
	fixtures :stream_links
  setup do
    @stream_link = stream_links(:one)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:stream_links)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_stream_link
    assert_difference('StreamLink.count') do
      post :create, :stream_link => @stream_link.attributes
    end

    assert_redirected_to stream_link_path(assigns(:stream_link))
  end

def test_should_show_stream_link
    get :show, :id => @stream_link.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @stream_link.to_param
    assert_response :success
  end

def test_should_update_stream_link
    put :update, :id => @stream_link.to_param, :stream_link => @stream_link.attributes
    assert_redirected_to stream_link_path(assigns(:stream_link))
  end

def test_should_destroy_stream_link
    assert_difference('StreamLink.count', -1) do
      delete :destroy, :id => @stream_link.to_param
    end

    assert_redirected_to stream_links_path
  end
end
