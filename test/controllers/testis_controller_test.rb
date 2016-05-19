require 'test_helper'

class TestisControllerTest < ActionController::TestCase
  setup do
    @testis = testis(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:testis)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create testis" do
    assert_difference('Testi.count') do
      post :create, testis: { age: @testis.age, city: @testis.city, name: @testis.name }
    end

    assert_redirected_to testis_path(assigns(:testis))
  end

  test "should show testis" do
    get :show, id: @testis
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @testis
    assert_response :success
  end

  test "should update testis" do
    patch :update, id: @testis, testis: { age: @testis.age, city: @testis.city, name: @testis.name }
    assert_redirected_to testis_path(assigns(:testis))
  end

  test "should destroy testis" do
    assert_difference('Testi.count', -1) do
      delete :destroy, id: @testis
    end

    assert_redirected_to testis_path
  end
end
