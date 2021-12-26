class AddCurrentProfileIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :current_profile_id, :integer
  end
end
