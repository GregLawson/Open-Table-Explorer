require 'test_helper'

class AcquisitionStreamSpecsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:acquisition_stream_specs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_acquisition_stream_spec
    assert_difference('AcquisitionStreamSpec.count') do
      post :create, :acquisition_stream_spec => { }
    end

    assert_redirected_to acquisition_stream_spec_path(assigns(:acquisition_stream_spec))
  end

  def test_should_show_acquisition_stream_spec
    get :show, :id => acquisition_stream_specs(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => acquisition_stream_specs(:one).id
    assert_response :success
  end

  def test_should_update_acquisition_stream_spec
    put :update, :id => acquisition_stream_specs(:one).id, :acquisition_stream_spec => { }
    assert_redirected_to acquisition_stream_spec_path(assigns(:acquisition_stream_spec))
  end

  def test_should_destroy_acquisition_stream_spec
    assert_difference('AcquisitionStreamSpec.count', -1) do
      delete :destroy, :id => acquisition_stream_specs(:one).id
    end

    assert_redirected_to acquisition_stream_specs_path
  end
end
