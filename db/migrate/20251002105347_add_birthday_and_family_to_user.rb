class AddBirthdayAndFamilyToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :birthday, :date
    add_column :users, :family, :string
  end
end
