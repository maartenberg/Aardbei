class CreateSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :sessions do |t|
      t.string :ip
      t.datetime :expires
      t.string :remember_digest, unique: true
      t.references :user, foreign_key: true
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
