require "application_system_test_case"

class DiariesTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  setup do
    @user1 = users(:one)
    @diary1 = diaries(:one)
    @user2 = users(:two)
    @diary2 = diaries(:two)
  end

  test "visiting the index" do
    visit diaries_url
    assert_selector "h1", text: "一覧"
  end

  test "should create diary" do
    login_as(@user2)
    visit diaries_url

    click_on "日記"
    click_on "新規投稿"

    fill_in "内容", with: @diary2.description
    fill_in "日付", with: @diary2.published_at
    fill_in "タイトル", with: @diary2.title
    click_on "投稿"

    assert_text "日記を登録しました。"
  end

  test "should update Diary" do
    login_as(@user2)
    visit diary_url(@diary2)
    click_on "編集", match: :first

    fill_in "内容", with: @diary2.description
    fill_in "日付", with: @diary2.published_at
    fill_in "タイトル", with: @diary2.title
    click_on "更新"

    assert_text "日記を更新しました。"
  end

  test "should destroy Diary" do
    login_as(@user1)
    visit diary_url(@diary1)
    accept_confirm do
      click_on "削除", match: :first
    end

    assert_text "日記を削除しました。"
  end
end
