class CreateDailyChats < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_chats do |t|
      t.references :user, null: false, foreign_key: true
      t.date :chat_date

      t.timestamps
    end
  end
end
