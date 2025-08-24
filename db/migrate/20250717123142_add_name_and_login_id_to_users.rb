class AddNameAndLoginIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string
    add_column :users, :login_id, :string

    User.find_each do |user| # 既存データに仮指定
      user.update!(
        name: user.email.split('@').first,
        login_id: user.email.split('@').first
      )
    end

    change_column_null :users, :name, false
    change_column_null :users, :login_id, false

    add_index :users, :login_id, unique: true
  end
end
