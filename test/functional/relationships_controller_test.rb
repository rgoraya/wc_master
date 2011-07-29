require 'test_helper'

class RelationshipsControllerTest < ActionController::TestCase
  setup do
    @relationship = relationships(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:relationships)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create relationship" do
    assert_difference('Relationship.count') do
      post :create, :relationship => @relationship.attributes
    end

    assert_redirected_to relationship_path(assigns(:relationship))
  end

  test "should show relationship" do
    get :show, :id => @relationship.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @relationship.to_param
    assert_response :success
  end

  test "should update relationship" do
    put :update, :id => @relationship.to_param, :relationship => @relationship.attributes
    assert_redirected_to relationship_path(assigns(:relationship))
  end

  test "should destroy relationship" do
    assert_difference('Relationship.count', -1) do
      delete :destroy, :id => @relationship.to_param
    end

    assert_redirected_to relationships_path
  end
end
