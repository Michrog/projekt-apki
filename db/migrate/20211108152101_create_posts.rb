class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.text :content
      t.date :post_date
      t.string :post_group
      t.string :title
      t.references :profile, null: false, foreign_key: true

      t.timestamps
    end
  end
end
