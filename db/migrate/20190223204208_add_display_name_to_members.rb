class AddDisplayNameToMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :display_name, :string
    add_index :members, [:group_id, :display_name], unique: true
  end
end
