require 'test_helper'

class ParseSpecsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:parse_specs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_parse_spec
    assert_difference('ParseSpec.count') do
      post :create, :parse_spec => { }
    end

    assert_redirected_to parse_spec_path(assigns(:parse_spec))
  end

  def test_should_show_parse_spec
    get :show, :id => parse_specs(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => parse_specs(:one).id
    assert_response :success
  end

  def test_should_update_parse_spec
    put :update, :id => parse_specs(:one).id, :parse_spec => { }
    assert_redirected_to parse_spec_path(assigns(:parse_spec))
  end

  def test_should_destroy_parse_spec
    assert_difference('ParseSpec.count', -1) do
      delete :destroy, :id => parse_specs(:one).id
    end

    assert_redirected_to parse_specs_path
  end
end
