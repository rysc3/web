require "test_helper"

class DataSortsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @data_sort = data_sorts(:one)
  end

  test "should get index" do
    get data_sorts_url
    assert_response :success
  end

  test "should get new" do
    get new_data_sort_url
    assert_response :success
  end

  test "should create data_sort" do
    assert_difference("DataSort.count") do
      post data_sorts_url, params: { data_sort: {  } }
    end

    assert_redirected_to data_sort_url(DataSort.last)
  end

  test "should show data_sort" do
    get data_sort_url(@data_sort)
    assert_response :success
  end

  test "should get edit" do
    get edit_data_sort_url(@data_sort)
    assert_response :success
  end

  test "should update data_sort" do
    patch data_sort_url(@data_sort), params: { data_sort: {  } }
    assert_redirected_to data_sort_url(@data_sort)
  end

  test "should destroy data_sort" do
    assert_difference("DataSort.count", -1) do
      delete data_sort_url(@data_sort)
    end

    assert_redirected_to data_sorts_url
  end
end
