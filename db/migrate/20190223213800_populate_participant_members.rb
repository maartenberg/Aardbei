class PopulateParticipantMembers < ActiveRecord::Migration[5.0]
  def down; end

  def up
    Participant.includes(:activity).each do |p|
      p.member = Member.find_by! person_id: p.person_id, group_id: p.activity.group_id
      p.save!
    end
  end
end
