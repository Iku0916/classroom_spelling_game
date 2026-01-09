require "test_helper"

class GamePlaysControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get game_plays_show_url
    assert_response :success
  end

  test "should get update" do
    get game_plays_update_url
    assert_response :success
  end
end
