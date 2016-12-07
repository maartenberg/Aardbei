class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_hash
      t.string :confirmation_token
      t.string :password_reset_token
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
