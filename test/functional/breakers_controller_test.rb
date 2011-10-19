require 'test_helper'

class BreakersControllerTest < ActionController::TestCase
fixtures :breakers
 def setup
    @breaker = breakers(:one)
  end
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:breakers)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_breaker
    assert_difference('Breaker.count') do
	    breaker_attributes=@breaker.attributes
	    breaker_attributes[:node]=99999
      post :create, :breaker => breaker_attributes
    end

    assert_redirected_to breaker_path(assigns(:breaker))
  end

  def test_should_show_breaker
    get :show, :id => breakers(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => breakers(:one).id
    assert_response :success
  end

  def test_should_update_breaker
    put :update, :id => breakers(:one).id, :breaker => { }
    assert_redirected_to breaker_path(assigns(:breaker))
  end

  def test_should_destroy_breaker
    assert_difference('Breaker.count', -1) do
      delete :destroy, :id => breakers(:one).id
    end

    assert_redirected_to breakers_path
  end
end
