require "test_helper"

class BookshelvesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bookshelf = bookshelves(:one)
  end

  test "should get index" do
    get bookshelves_url
    assert_response :success
  end

  test "should get new" do
    get new_bookshelf_url
    assert_response :success
  end

  test "should create bookshelf" do
    assert_difference("Bookshelf.count") do
      post bookshelves_url, params: { bookshelf: {  } }
    end

    assert_redirected_to bookshelf_url(Bookshelf.last)
  end

  test "should show bookshelf" do
    get bookshelf_url(@bookshelf)
    assert_response :success
  end

  test "should get edit" do
    get edit_bookshelf_url(@bookshelf)
    assert_response :success
  end

  test "should update bookshelf" do
    patch bookshelf_url(@bookshelf), params: { bookshelf: {  } }
    assert_redirected_to bookshelf_url(@bookshelf)
  end

  test "should destroy bookshelf" do
    assert_difference("Bookshelf.count", -1) do
      delete bookshelf_url(@bookshelf)
    end

    assert_redirected_to bookshelves_url
  end
end
