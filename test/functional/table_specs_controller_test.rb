require 'test_helper'

class TableSpecsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:table_specs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_table_spec
    assert_difference('TableSpec.count') do
      post :create, :table_spec => { }
    end

    assert_redirected_to table_spec_path(assigns(:table_spec))
  end

  def test_should_show_table_spec
    get :show, :id => table_specs(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => table_specs(:one).id
    assert_response :success
  end

  def test_should_update_table_spec
    put :update, :id => table_specs(:one).id, :table_spec => { }
    assert_redirected_to table_spec_path(assigns(:table_spec))
  end

  def test_should_destroy_table_spec
    assert_difference('TableSpec.count', -1) do
      delete :destroy, :id => table_specs(:one).id
    end

    assert_redirected_to table_specs_path
  end
end
