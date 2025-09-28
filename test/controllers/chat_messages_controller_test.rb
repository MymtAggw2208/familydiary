require "test_helper"

class ChatMessagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
    @daily_chat = DailyChat.create!(user: @user, chat_date: Date.current)
  end

  test "should get create" do
    post daily_chat_chat_messages_path(@daily_chat),
        params: { chat_message: { content: "テストメッセージ" } }
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end
end
