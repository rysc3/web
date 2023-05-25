require "application_system_test_case"

class BookshelvesTest < ApplicationSystemTestCase
  setup do
    @bookshelf = bookshelves(:one)
  end

  test "visiting the index" do
    visit bookshelves_url
    assert_selector "h1", text: "Bookshelves"
  end

  test "should create bookshelf" do
    visit bookshelves_url
    click_on "New bookshelf"

    click_on "Create Bookshelf"

    assert_text "Bookshelf was successfully created"
    click_on "Back"
  end

  test "should update Bookshelf" do
    visit bookshelf_url(@bookshelf)
    click_on "Edit this bookshelf", match: :first

    click_on "Update Bookshelf"

    assert_text "Bookshelf was successfully updated"
    click_on "Back"
  end

  test "should destroy Bookshelf" do
    visit bookshelf_url(@bookshelf)
    click_on "Destroy this bookshelf", match: :first

    assert_text "Bookshelf was successfully destroyed"
  end
end
