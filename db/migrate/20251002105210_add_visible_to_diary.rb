class AddVisibleToDiary < ActiveRecord::Migration[8.0]
  def change
    add_column :diaries, :visible, :boolean
  end
end
