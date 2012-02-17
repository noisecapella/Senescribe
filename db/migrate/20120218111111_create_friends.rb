class CreateFriends < ActiveRecord::Migration
  def change
    create_table :users_users, :id => false do |t|
      t.integer :user_id, :null => false
      t.integer :user_to_id, :null => false
    end
  end
end
