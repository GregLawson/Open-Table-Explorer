require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
fixtures :accounts
def test_should get index
    get :index
    assert_response :success
    assert_not_nil assigns(:accounts)
  end

def test_should get new
    get :new
    assert_response :success
  end

def test_should create account
    assert_difference('Account.count') do
      post :create, :account => { }
    end

    assert_redirected_to account_path(assigns(:account))
  end

def test_should show account
    get :show, :id => accounts('Roth Conversion'.to_sym).id
    assert_response :success
  end

def test_should get edit
    get :edit, :id => accounts('Roth Conversion'.to_sym).id
    assert_response :success
  end

def test_should update account
    put :update, :id => accounts('Roth Conversion'.to_sym).id, :account => { }
    assert_redirected_to account_path(assigns(:account))
  end

def test_should destroy account
    assert_difference('Account.count', -1) do
      delete :destroy, :id => accounts('Roth Conversion'.to_sym).id
    end

    assert_redirected_to accounts_path
  end
end
