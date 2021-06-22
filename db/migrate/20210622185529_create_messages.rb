class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.text :content
      t.string :from
      t.references :user_friend

      t.timestamps
    end
  end
end
