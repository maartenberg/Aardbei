class EnforceManyToManyUniqueness < ActiveRecord::Migration[5.0]
  def change
    add_index :participants, [:person_id, :activity_id], unique: true
    add_index :members,      [:person_id, :group_id],    unique: true

    remove_index :users, [:person_id]
    add_index    :users, [:person_id], unique: true
  end
end
