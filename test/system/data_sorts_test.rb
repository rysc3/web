require "application_system_test_case"

class DataSortsTest < ApplicationSystemTestCase
  setup do
    @data_sort = data_sorts(:one)
  end

  test "visiting the index" do
    visit data_sorts_url
    assert_selector "h1", text: "Data sorts"
  end

  test "should create data sort" do
    visit data_sorts_url
    click_on "New data sort"

    click_on "Create Data sort"

    assert_text "Data sort was successfully created"
    click_on "Back"
  end

  test "should update Data sort" do
    visit data_sort_url(@data_sort)
    click_on "Edit this data sort", match: :first

    click_on "Update Data sort"

    assert_text "Data sort was successfully updated"
    click_on "Back"
  end

  test "should destroy Data sort" do
    visit data_sort_url(@data_sort)
    click_on "Destroy this data sort", match: :first

    assert_text "Data sort was successfully destroyed"
  end
end
