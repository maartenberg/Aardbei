class UniqueEmailsForPersonsAndUsers < ActiveRecord::Migration[5.0]
  def change
    add_index :users, [:email], unique: true
    add_index :people, [:email], unique: true
  end
end
