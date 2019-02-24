class RemovePersonFromParticipants < ActiveRecord::Migration[5.0]
  def change
    remove_index :participants, column: [:person_id, :activity_id], unique: true
    add_index :participants, [:member_id, :activity_id], unique: true
    remove_reference :participants, :person, foreign_key: true
  end
end
