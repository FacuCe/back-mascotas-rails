class CreateUserFriends < ActiveRecord::Migration[6.1]
  def change
    create_table :user_friends do |t|
      t.references :user
      t.integer :friend_id
      t.boolean :accepted, default: false

      t.timestamps
    end
  end
end
