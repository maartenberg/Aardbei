class CreatePeople < ActiveRecord::Migration[5.0]
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :infix
      t.string :last_name
      t.date :birth_date
      t.string :email
      t.boolean :is_admin

      t.timestamps
    end
  end
end
