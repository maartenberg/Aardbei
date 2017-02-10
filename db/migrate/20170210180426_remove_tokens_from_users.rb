class RemoveTokensFromUsers < ActiveRecord::Migration[5.0]
  def up
    remove_column :users, :confirmation_token
    remove_column :users, :password_reset_token

    create_table :tokens do |t|
      t.string    :token
      t.datetime  :expires
      t.string    :tokentype
      t.integer   :user_id
      t.index ["token"], name: "index_tokens_on_token", unique: true
    end
  end

  def down
    add_column :users, :confirmation_token, :string
    add_column :users, :password_reset_token, :string

    drop_table :tokens
  end
end
