require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @diary = diaries(:one)
    sign_in @user
    @comment = comments(:one)
  end

  test "should get create" do
    post diary_comments_path(@diary), params: { comment: { content: "テストコメント" } }
    assert_response :redirect
  end

  test "should get destroy" do
    delete diary_comment_path(@diary, @comment)
    assert_response :redirect
  end
end
