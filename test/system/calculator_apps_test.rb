require "application_system_test_case"

class CalculatorAppsTest < ApplicationSystemTestCase
  setup do
    @calculator_app = calculator_apps(:one)
  end

  test "visiting the index" do
    visit calculator_apps_url
    assert_selector "h1", text: "Calculator apps"
  end

  test "should create calculator app" do
    visit calculator_apps_url
    click_on "New calculator app"

    click_on "Create Calculator app"

    assert_text "Calculator app was successfully created"
    click_on "Back"
  end

  test "should update Calculator app" do
    visit calculator_app_url(@calculator_app)
    click_on "Edit this calculator app", match: :first

    click_on "Update Calculator app"

    assert_text "Calculator app was successfully updated"
    click_on "Back"
  end

  test "should destroy Calculator app" do
    visit calculator_app_url(@calculator_app)
    click_on "Destroy this calculator app", match: :first

    assert_text "Calculator app was successfully destroyed"
  end
end
