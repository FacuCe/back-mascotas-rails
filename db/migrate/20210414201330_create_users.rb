class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :login
      t.string :password
      t.boolean :enabled, default: true

      t.timestamps
    end
  end
end
