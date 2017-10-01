class AddSubgroupToParticipants < ActiveRecord::Migration[5.0]
  def change
    add_reference :participants, :subgroup, foreign_key: true
  end
end
