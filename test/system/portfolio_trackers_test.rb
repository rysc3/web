require "application_system_test_case"

class PortfolioTrackersTest < ApplicationSystemTestCase
  setup do
    @portfolio_tracker = portfolio_trackers(:one)
  end

  test "visiting the index" do
    visit portfolio_trackers_url
    assert_selector "h1", text: "Portfolio trackers"
  end

  test "should create portfolio tracker" do
    visit portfolio_trackers_url
    click_on "New portfolio tracker"

    click_on "Create Portfolio tracker"

    assert_text "Portfolio tracker was successfully created"
    click_on "Back"
  end

  test "should update Portfolio tracker" do
    visit portfolio_tracker_url(@portfolio_tracker)
    click_on "Edit this portfolio tracker", match: :first

    click_on "Update Portfolio tracker"

    assert_text "Portfolio tracker was successfully updated"
    click_on "Back"
  end

  test "should destroy Portfolio tracker" do
    visit portfolio_tracker_url(@portfolio_tracker)
    click_on "Destroy this portfolio tracker", match: :first

    assert_text "Portfolio tracker was successfully destroyed"
  end
end
