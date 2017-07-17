require 'test_helper'

class TestappsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @testapp = testapps(:one)
  end

  test "should get index" do
    get testapps_url
    assert_response :success
  end

  test "should get new" do
    get new_testapp_url
    assert_response :success
  end

  test "should create testapp" do
    assert_difference('Testapp.count') do
      post testapps_url, params: { testapp: { body: @testapp.body, name: @testapp.name } }
    end

    assert_redirected_to testapp_url(Testapp.last)
  end

  test "should show testapp" do
    get testapp_url(@testapp)
    assert_response :success
  end

  test "should get edit" do
    get edit_testapp_url(@testapp)
    assert_response :success
  end

  test "should update testapp" do
    patch testapp_url(@testapp), params: { testapp: { body: @testapp.body, name: @testapp.name } }
    assert_redirected_to testapp_url(@testapp)
  end

  test "should destroy testapp" do
    assert_difference('Testapp.count', -1) do
      delete testapp_url(@testapp)
    end

    assert_redirected_to testapps_url
  end
end
