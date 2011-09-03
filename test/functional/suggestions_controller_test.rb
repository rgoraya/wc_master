require 'test_helper'

class SuggestionsControllerTest < ActionController::TestCase
  setup do
    @suggestion = suggestions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:suggestions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create suggestion" do
    assert_difference('Suggestion.count') do
      post :create, :suggestion => @suggestion.attributes
    end

    assert_redirected_to suggestion_path(assigns(:suggestion))
  end

  test "should show suggestion" do
    get :show, :id => @suggestion.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @suggestion.to_param
    assert_response :success
  end

  test "should update suggestion" do
    put :update, :id => @suggestion.to_param, :suggestion => @suggestion.attributes
    assert_redirected_to suggestion_path(assigns(:suggestion))
  end

  test "should destroy suggestion" do
    assert_difference('Suggestion.count', -1) do
      delete :destroy, :id => @suggestion.to_param
    end

    assert_redirected_to suggestions_path
  end
end
