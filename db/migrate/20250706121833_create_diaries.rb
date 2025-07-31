class CreateDiaries < ActiveRecord::Migration[8.0]
  def change
    create_table :diaries do |t|
      t.string :title
      t.text :description
      t.string :picture
      t.date :published_at

      t.timestamps
    end
  end
end
