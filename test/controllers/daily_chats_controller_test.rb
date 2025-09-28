require "test_helper"

class DailyChatsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get daily_chats_show_url
    assert_response :success
  end

  test "should get show_date" do
    get daily_chats_show_date_url
    assert_response :success
  end

  test "should get history" do
    get daily_chats_history_url
    assert_response :success
  end

  test "should get clear_messages" do
    get daily_chats_clear_messages_url
    assert_response :success
  end
end
