require 'test_helper'

class BugsControllerTest < ActionController::TestCase
fixtures :bugs
@@fixture_example_name="http://mobiledell.lan:3000/bugs/new"
  setup do
	assert_fixture_name(:bugs)
  	assert_include(@@fixture_example_name, fixture_labels(:bugs))
	@bug = bugs(@@fixture_example_name)
	@bug[:url]='unique key'
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bugs)
  end #index

  test "should show bug" do
    get :show, :id => @bug.to_param
    assert_response :success
  end #show
  test "should get new" do
    get :new
    assert_response :success
  end #new
  test "should get edit" do
    get :edit, :id => @bug.to_param
    assert_response :success
  end #edit


  test "should create bug" do
    assert_difference('Bug.count') do
      post :create, :bug => @bug.attributes
    end

    assert_redirected_to bug_path(assigns(:bug))
  end #create


  test "should update bug" do
    put :update, :id => @bug.to_param, :bug => @bug.attributes
    assert_redirected_to bug_path(assigns(:bug))
  end #update

  test "should destroy bug" do
    assert_difference('Bug.count', -1) do
      delete :destroy, :id => @bug.to_param
    end

    assert_redirected_to bugs_path
  end #destroy
end #class
