require 'test_helper'

class FeedBacksControllerTest < ActionController::TestCase
  setup do
    @feed_back = feed_backs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:feed_backs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create feed_back" do
    assert_difference('FeedBack.count') do
      post :create, :feed_back => @feed_back.attributes
    end

    assert_redirected_to feed_back_path(assigns(:feed_back))
  end

  test "should show feed_back" do
    get :show, :id => @feed_back.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @feed_back.to_param
    assert_response :success
  end

  test "should update feed_back" do
    put :update, :id => @feed_back.to_param, :feed_back => @feed_back.attributes
    assert_redirected_to feed_back_path(assigns(:feed_back))
  end

  test "should destroy feed_back" do
    assert_difference('FeedBack.count', -1) do
      delete :destroy, :id => @feed_back.to_param
    end

    assert_redirected_to feed_backs_path
  end
end
