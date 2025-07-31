require "application_system_test_case"

class DiariesTest < ApplicationSystemTestCase
  setup do
    @diary = diaries(:one)
  end

  test "visiting the index" do
    visit diaries_url
    assert_selector "h1", text: "Diaries"
  end

  test "should create diary" do
    visit diaries_url
    click_on "New diary"

    fill_in "Description", with: @diary.description
    fill_in "Picture", with: @diary.picture
    fill_in "Published at", with: @diary.published_at
    fill_in "Title", with: @diary.title
    click_on "Create Diary"

    assert_text "Diary was successfully created"
    click_on "Back"
  end

  test "should update Diary" do
    visit diary_url(@diary)
    click_on "Edit this diary", match: :first

    fill_in "Description", with: @diary.description
    fill_in "Picture", with: @diary.picture
    fill_in "Published at", with: @diary.published_at
    fill_in "Title", with: @diary.title
    click_on "Update Diary"

    assert_text "Diary was successfully updated"
    click_on "Back"
  end

  test "should destroy Diary" do
    visit diary_url(@diary)
    click_on "Destroy this diary", match: :first

    assert_text "Diary was successfully destroyed"
  end
end
