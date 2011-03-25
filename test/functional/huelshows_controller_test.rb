require 'test_helper'

class HuelshowsControllerTest < ActionController::TestCase
  setup do
    @huelshow = huelshows(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:huelshows)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create huelshow" do
    assert_difference('Huelshow.count') do
	    huelshow_attributes=@huelshow.attributes
	    huelshow_attributes[:shortname]='test create record'
	    huelshow_attributes[:name]='test create record'
      post :create, :huelshow => huelshow_attributes
    end

    assert_redirected_to huelshow_path(assigns(:huelshow))
  end

  test "should show huelshow" do
    get :show, :id => @huelshow.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @huelshow.to_param
    assert_response :success
  end

  test "should update huelshow" do
    put :update, :id => @huelshow.to_param, :huelshow => @huelshow.attributes
    assert_redirected_to huelshow_path(assigns(:huelshow))
  end

  test "should destroy huelshow" do
    assert_difference('Huelshow.count', -1) do
      delete :destroy, :id => @huelshow.to_param
    end

    assert_redirected_to huelshows_path
  end
end
