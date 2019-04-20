class AddMemberToParticipant < ActiveRecord::Migration[5.0]
  def change
    add_reference :participants, :member, foreign_key: true, on_delete: :nullify
  end
end
