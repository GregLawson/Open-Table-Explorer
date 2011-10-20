require 'test_helper'

class TestRunsControllerTest < ActionController::TestCase
	fixtures :test_runs
  setup do
    @test_run = test_runs(:one)
  end

def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:test_runs)
  end

def test_should_get_new
    get :new
    assert_response :success
  end

def test_should_create_test_run
    assert_difference('TestRun.count') do
      post :create, :test_run => @test_run.attributes
    end

    assert_redirected_to test_run_path(assigns(:test_run))
  end

def test_should_show_test_run
    get :show, :id => @test_run.to_param
    assert_response :success
  end

def test_should_get_edit
    get :edit, :id => @test_run.to_param
    assert_response :success
  end

def test_should_update_test_run
    put :update, :id => @test_run.to_param, :test_run => @test_run.attributes
    assert_redirected_to test_run_path(assigns(:test_run))
  end

def test_should_destroy_test_run
    assert_difference('TestRun.count', -1) do
      delete :destroy, :id => @test_run.to_param
    end

    assert_redirected_to test_runs_path
  end
end
