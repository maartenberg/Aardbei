class DisallowNullParticipantPerson < ActiveRecord::Migration[5.0]
  def up
    fixed_missing_member = 0
    ps = Participant.where(member_id: nil)
    ps.each do |p|
      member = Member.find_by person: p.person, group: p.activity.group
      if member.present?
        p.member = member
        p.save!
        fixed_missing_member += 1
      end
    end

    fixed_missing_person = 0
    ps = Participant.where(person_id: nil)
    ps.each do |p|
      p.person = p.member.person
      p.save!
      fixed_missing_person += 1
    end

    puts "fixed #{fixed_missing_member} missing members, #{fixed_missing_person} missing people"

    change_column_null :participants, :person_id, false
  end

  def down
    change_column_null :participants, :person_id, true
  end
end
