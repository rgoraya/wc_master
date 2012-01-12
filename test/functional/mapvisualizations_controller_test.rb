require 'test_helper'

class MapvisualizationsControllerTest < ActionController::TestCase
  setup do
    @mapvisualization = mapvisualizations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mapvisualizations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mapvisualization" do
    assert_difference('Mapvisualization.count') do
      post :create, :mapvisualization => @mapvisualization.attributes
    end

    assert_redirected_to mapvisualization_path(assigns(:mapvisualization))
  end

  test "should show mapvisualization" do
    get :show, :id => @mapvisualization.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @mapvisualization.to_param
    assert_response :success
  end

  test "should update mapvisualization" do
    put :update, :id => @mapvisualization.to_param, :mapvisualization => @mapvisualization.attributes
    assert_redirected_to mapvisualization_path(assigns(:mapvisualization))
  end

  test "should destroy mapvisualization" do
    assert_difference('Mapvisualization.count', -1) do
      delete :destroy, :id => @mapvisualization.to_param
    end

    assert_redirected_to mapvisualizations_path
  end
end
