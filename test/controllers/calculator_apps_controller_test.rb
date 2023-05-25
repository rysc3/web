require "test_helper"

class CalculatorAppsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @calculator_app = calculator_apps(:one)
  end

  test "should get index" do
    get calculator_apps_url
    assert_response :success
  end

  test "should get new" do
    get new_calculator_app_url
    assert_response :success
  end

  test "should create calculator_app" do
    assert_difference("CalculatorApp.count") do
      post calculator_apps_url, params: { calculator_app: {  } }
    end

    assert_redirected_to calculator_app_url(CalculatorApp.last)
  end

  test "should show calculator_app" do
    get calculator_app_url(@calculator_app)
    assert_response :success
  end

  test "should get edit" do
    get edit_calculator_app_url(@calculator_app)
    assert_response :success
  end

  test "should update calculator_app" do
    patch calculator_app_url(@calculator_app), params: { calculator_app: {  } }
    assert_redirected_to calculator_app_url(@calculator_app)
  end

  test "should destroy calculator_app" do
    assert_difference("CalculatorApp.count", -1) do
      delete calculator_app_url(@calculator_app)
    end

    assert_redirected_to calculator_apps_url
  end
end
