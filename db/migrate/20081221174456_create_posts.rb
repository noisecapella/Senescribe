class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :blog_id
      t.string :subject
      t.string :text
      t.boolean :is_viewable
      t.text :serialized_words
      t.string :autosave_text

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
