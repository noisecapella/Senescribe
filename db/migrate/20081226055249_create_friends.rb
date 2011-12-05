class CreateFriends < ActiveRecord::Migration
  def self.up
    create_table :users_users, :id => false do |t|
      t.integer :user_id, :null => false
      t.integer :user_to_id, :null => false
    end
  end

  def self.down
    drop_table :users_users
    #drop_table :friends
  end
end
