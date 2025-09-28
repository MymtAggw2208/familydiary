require "test_helper"

class DailyChatsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get today" do
    get today_daily_chats_url
    assert_response :success
  end

  test "should get show_date" do
    get date_daily_chats_url(date: Date.today.to_s)
    assert_response :success
  end

  test "should get history" do
    get history_daily_chats_url
    assert_response :success
  end

  test "should get clear_messages" do
    get clear_messages_daily_chats_url
    assert_response :success
  end
end
