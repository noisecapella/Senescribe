# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090111182908) do

  create_table "blogs", :force => true do |t|
    t.integer  "style_id"
    t.string   "title"
    t.string   "description"
    t.integer  "user_id"
    t.integer  "posts_per_page"
    t.integer  "comments_per_page"
    t.integer  "autosaved_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.string   "text"
    t.string   "subject"
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "posts", :force => true do |t|
    t.integer  "blog_id"
    t.string   "subject"
    t.string   "text"
    t.boolean  "is_viewable"
    t.text     "serialized_words"
    t.string   "autosave_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "styles", :force => true do |t|
    t.string   "stylesheet"
    t.string   "css"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "description"
    t.integer  "blog_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identity_url"
  end

  create_table "users_users", :id => false, :force => true do |t|
    t.integer "user_id",    :null => false
    t.integer "user_to_id", :null => false
  end

  create_table "words", :force => true do |t|
    t.text     "word"
    t.integer  "current_position"
    t.integer  "current_index"
    t.integer  "post_id"
    t.datetime "created_at"
  end

end
