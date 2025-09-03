require "application_system_test_case"

class DiariesTest < ApplicationSystemTestCase
  
  setup do
    @user1 = users(:one) 
    @diary1 = diaries(:one)
    @user2 = users(:two) 
    @diary2 = diaries(:two)
  end

  def login_as(user)
    visit new_user_session_path
    fill_in "ログインID", with: user.login_id
    fill_in "パスワード", with: "password1"
    click_on "ログイン"
  end

  test "visiting the index" do
    visit diaries_url
    assert_selector "h1", text: "一覧"
  end

  test "should create diary" do
    login_as(@user1)
    visit diaries_url
    click_on "新規投稿"

    fill_in "内容", with: @diary.description
    fill_in "画像", with: @diary.picture
    fill_in "日付", with: @diary.published_at
    fill_in "タイトル", with: @diary.title
    click_on "投稿"

    assert_text "Diary was successfully created"
  end

  test "should update Diary" do
    login_as(@user2)
    visit diary_url(@diary2)
    save_page
    click_on "編集", match: :first

    fill_in "内容", with: @diary.description
    fill_in "画像", with: @diary.picture
    fill_in "日付", with: @diary.published_at
    fill_in "タイトル", with: @diary.title
    click_on "更新"

    assert_text "Diary was successfully updated"
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
