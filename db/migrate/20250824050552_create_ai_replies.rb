class CreateAiReplies < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_replies do |t|
      t.references :diary, null: false, foreign_key: true
      t.text :content
      t.datetime :replied_at

      t.timestamps
    end
  end
end
