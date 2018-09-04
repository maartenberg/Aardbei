class AddCalendarTokenToPeople < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :calendar_token, :string
    add_index :people, :calendar_token, unique: true
  end
end
