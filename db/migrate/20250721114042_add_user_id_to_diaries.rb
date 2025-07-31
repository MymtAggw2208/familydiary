class AddUserIdToDiaries < ActiveRecord::Migration[8.0]
  def up
    add_reference :diaries, :user, foreign_key: true

    # 最初のユーザーまたは指定したユーザーを取得
    default_user_id = User.exists?(1) ? 1 : User.first&.id
    
    if default_user_id
      Diary.where(user_id: nil).update_all(user_id: default_user_id)
      change_column_null :diaries, :user_id, false
    else
      raise "No users found. Please create users first."
    end
  end

  def down
    remove_reference :diaries, :user, foreign_key: true
  end
end