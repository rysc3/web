require "test_helper"

class PortfolioTrackersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @portfolio_tracker = portfolio_trackers(:one)
  end

  test "should get index" do
    get portfolio_trackers_url
    assert_response :success
  end

  test "should get new" do
    get new_portfolio_tracker_url
    assert_response :success
  end

  test "should create portfolio_tracker" do
    assert_difference("PortfolioTracker.count") do
      post portfolio_trackers_url, params: { portfolio_tracker: {  } }
    end

    assert_redirected_to portfolio_tracker_url(PortfolioTracker.last)
  end

  test "should show portfolio_tracker" do
    get portfolio_tracker_url(@portfolio_tracker)
    assert_response :success
  end

  test "should get edit" do
    get edit_portfolio_tracker_url(@portfolio_tracker)
    assert_response :success
  end

  test "should update portfolio_tracker" do
    patch portfolio_tracker_url(@portfolio_tracker), params: { portfolio_tracker: {  } }
    assert_redirected_to portfolio_tracker_url(@portfolio_tracker)
  end

  test "should destroy portfolio_tracker" do
    assert_difference("PortfolioTracker.count", -1) do
      delete portfolio_tracker_url(@portfolio_tracker)
    end

    assert_redirected_to portfolio_trackers_url
  end
end
