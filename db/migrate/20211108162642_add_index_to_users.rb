class AddIndexToUsers < ActiveRecord::Migration[6.1]
  def change
    add_index :users, :user_index, unique: true
  end
end
