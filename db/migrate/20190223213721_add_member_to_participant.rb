class AddMemberToParticipant < ActiveRecord::Migration[5.0]
  def change
    add_reference :participants, :member, foreign_key: true
  end
end
