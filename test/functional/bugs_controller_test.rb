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

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:bugs)
  end #index

def test_should_show_bug
    get :show, :id => @bug.to_param
    assert_response :success
  end #show
def test_should_get_new
    get :new
    assert_response :success
  end #new
def test_should_get_edit
    get :edit, :id => @bug.to_param
    assert_response :success
  end #edit


def test_should_create_bug
    assert_difference('Bug.count') do
      post :create, :bug => @bug.attributes
    end

    assert_redirected_to bug_path(assigns(:bug))
  end #create


def test_should_update_bug
    put :update, :id => @bug.to_param, :bug => @bug.attributes
    assert_redirected_to bug_path(assigns(:bug))
  end #update

def test_should_destroy_bug
    assert_difference('Bug.count', -1) do
      delete :destroy, :id => @bug.to_param
    end

    assert_redirected_to bugs_path
  end #destroy
end #class
