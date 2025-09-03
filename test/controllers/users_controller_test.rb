require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @deluser = users(:three)
    @admin = users(:admin) # 管理者ユーザーが必要
    sign_in @admin
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get show" do
    get user_url(@user.id)
    assert_response :success
  end

  test "should get edit other user" do
    get edit_other_user_registration_url(@user.id)
    assert_response :success
  end

  test "should update other user" do
    patch update_other_user_registration_url(@user.id), params: {
      user: { name: "Updated Name" }
    }
    assert_response :redirect
  end

  test "should destroy other user" do
    assert_difference("User.count", -1) do
      delete delete_other_user_registration_url(@deluser.id)
    end
    assert_response :redirect
  end
end
