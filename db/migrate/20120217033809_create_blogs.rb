class CreateBlogs < ActiveRecord::Migration
  def change
    create_table :blogs do |t|
      t.integer :style_id
      t.string :title
      t.string :description
      t.integer :user_id
      t.integer :posts_per_page
      t.integer :comments_per_page
      t.integer :autosaved_post_id

      t.timestamps
    end
  end
end
