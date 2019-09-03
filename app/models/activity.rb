# An Activity represents a single continuous event that the members of a group may attend.
# An Activity belongs to a group, and has many participants.
class Activity < ApplicationRecord
  # @!attribute name
  #   @return [String]
  #     a short name for the activity.
  #
  # @!attribute description
  #   @return [String]
  #     a short text describing the activity. This text is always visible to
  #     all users.
  #
  # @!attribute location
  #   @return [String]
  #     a short text describing where the activity will take place. Always
  #     visible to all participants.
  #
  # @!attribute start
  #   @return [TimeWithZone]
  #     when the activity starts.
  #
  # @!attribute end
  #   @return [TimeWithZone]
  #     when the activity ends.
  #
  # @!attribute deadline
  #   @return [TimeWithZone]
  #     when the normal participants (everyone who isn't an organizer or group
  #     leader) may not change their own attendance anymore. Disabled if set to
  #     nil.
  #
  # @!attribute reminder_at
  #   @return [TimeWithZone]
  #     when all participants which haven't responded yet (attending is nil)
  #     will be automatically set to 'present' and emailed. Must be before the
  #     deadline, disabled if nil.
  #
  # @!attribute reminder_done
  #   @return [Boolean]
  #     whether or not sending the reminder has finished.
  #
  # @!attribute subgroup_division_enabled
  #   @return [Boolean]
  #     whether automatic subgroup division on the deadline is enabled.
  #
  # @!attribute subgroup_division_done
  #   @return [Boolean]
  #     whether subgroup division has been performed.
  #
  # @!attribute no_response_action
  #   @return [Boolean]
  #     what action to take when a participant has not responded and the
  #     reminder is being sent. True to set the participant to attending, false
  #     to set to absent.

  belongs_to :group

  has_many :participants,
           dependent: :destroy
  has_many :people, through: :participants

  has_many :subgroups,
           dependent: :destroy

  validates :name, presence: true
  validates :start, presence: true
  validate  :deadline_before_start, unless: "self.deadline.blank?"
  validate  :end_after_start,       unless: "self.end.blank?"
  validate  :reminder_before_deadline, unless: "self.reminder_at.blank?"
  validate  :subgroups_for_division_present, on: :update

  after_create :create_missing_participants!
  after_create :copy_default_subgroups!
  after_create :schedule_reminder
  after_create :schedule_subgroup_division

  after_commit :schedule_reminder,
               if: proc { |a| a.previous_changes["reminder_at"] }
  after_commit :schedule_subgroup_division,
               if: proc { |a|
                     (a.previous_changes['deadline'] ||
                                   a.previous_changes['subgroup_division_enabled']) &&
                       !a.subgroup_division_done &&
                       a.subgroup_division_enabled
                   }

  # Get all people (not participants) that are organizers. Does not include
  # group leaders, although they may modify the activity as well.
  def organizers
    participants.includes(:member).where(is_organizer: true)
  end

  def organizer_names
    organizers.map(&:display_name)
  end

  # Determine whether the passed Person participates in the activity.
  def participant?(person)
    Participant.exists?(
      activity_id: id,
      person_id: person.id
    )
  end

  # Determine whether the passed Person is an organizer for the activity.
  def organizer?(person)
    Participant.includes(:person).exists?(
      "people.id" => person.id,
      activity_id: id,
      is_organizer: true
    )
  end

  # Query the database to determine the amount of participants that are present/absent/unknown
  def state_counts
    participants.group(:attending).count
  end

  # Return participants attending, absent, unknown
  def human_state_counts
    c = state_counts
    p = c[true]
    a = c[false]
    u = c[nil]
    "#{p || 0}, #{a || 0}, #{u || 0}"
  end

  # Determine whether the passed Person may change this activity.
  def may_change?(person)
    person.is_admin ||
      organizer?(person) ||
      group.leader?(person)
  end

  # Create Participants for all People that
  #  1. are members of the group
  #  2. do not have Participants (and thus, no way to confirm) yet
  def create_missing_participants!
    members = group
                  .members
                  .joins(:person)
    members = members.where('people.id NOT IN (?)', self.people.ids) unless participants.empty?

    members.each do |m|
      Participant.create!(
        activity: self,
        member: m,
        person: m.person
      )
    end
  end

  # Create Subgroups from the defaults set using DefaultSubgroups
  def copy_default_subgroups!
    defaults = group.default_subgroups

    # If there are no subgroups, there cannot be subgroup division.
    update!(subgroup_division_enabled: false) if defaults.none?

    defaults.each do |dsg|
      sg = Subgroup.new(activity: self)
      sg.name = dsg.name
      sg.is_assignable = dsg.is_assignable
      sg.save! # Should never fail, as DSG and SG have identical validation, and names cannot clash.
    end
  end

  # Create multiple Activities from data in a CSV file, assign to a group, return.
  def self.from_csv(content, group)
    reader = CSV.parse(content, headers: true, skip_blanks: true)

    result = []
    reader.each do |row|
      a = Activity.new
      a.group       = group
      a.name        = row['name']
      a.description = row['description']
      a.location    = row['location']

      sd            = Date.parse row['start_date']
      st            = Time.strptime(row['start_time'], '%H:%M')
      a.start       = Time.zone.local(sd.year, sd.month, sd.day, st.hour, st.min)

      if row['end_date'].present?
        ed          = Date.parse row['end_date']
        et          = Time.strptime(row['end_time'], '%H:%M')
        a.end       = Time.zone.local(ed.year, ed.month, ed.day, et.hour, et.min)
      end

      if row['deadline_date'].present?
        dd            = Date.parse row['deadline_date']
        dt            = Time.strptime(row['deadline_time'], '%H:%M')
        a.deadline    = Time.zone.local(dd.year, dd.month, dd.day, dt.hour, dt.min)
      end

      if row['reminder_at_date'].present?
        rd            = Date.parse row['reminder_at_date']
        rt            = Time.strptime(row['reminder_at_time'], '%H:%M')
        a.reminder_at = Time.zone.local(rd.year, rd.month, rd.day, rt.hour, rt.min)
      end

      a.subgroup_division_enabled = row['subgroup_division_enabled'].casecmp('y').zero? if row['subgroup_division_enabled'].present?

      a.no_response_action = row['no_response_action'].casecmp('p').zero? if row['no_response_action'].present?

      result << a
    end

    result
  end

  # Send a reminder to all participants who haven't responded, and set their
  # response to 'attending'.
  def send_reminder
    # Sanity check that the reminder date didn't change while queued.
    return unless !reminder_done && reminder_at
    return if reminder_at > Time.zone.now

    participants = self.participants.where(attending: nil)
    participants.each(&:send_reminder)

    self.reminder_done = true
    save
  end

  def schedule_reminder
    return if reminder_at.nil? || reminder_done

    delay(run_at: reminder_at).send_reminder
  end

  def schedule_subgroup_division
    return if deadline.nil? || subgroup_division_done

    delay(run_at: deadline).assign_subgroups!(mail: true)
  end

  # Assign a subgroup to all attending participants without one.
  def assign_subgroups!(mail = false)
    # Sanity check: we need subgroups to divide into.
    return unless subgroups.any?

    # Get participants in random order
    ps =
      participants
      .where(attending: true)
      .where(subgroup: nil)
      .to_a

    ps.shuffle!

    # Get groups, link to participant count
    groups =
      subgroups
      .where(is_assignable: true)
      .to_a
      .map { |sg| [sg.participants.count, sg] }

    ps.each do |p|
      # Sort groups so the group with the least participants gets the following participant
      groups.sort!

      # Assign participant to group with least members
      p.subgroup = groups.first.second
      p.save

      # Update the group's position in the list, will sort when next participant is processed.
      groups.first[0] += 1
    end

    notify_subgroups! if mail
  end

  def clear_subgroups!(only_assignable = true)
    sgs =
      subgroups

    if only_assignable
      sgs = sgs
            .where(is_assignable: true)
    end

    ps =
      participants
      .where(subgroup: sgs)

    ps.each do |p|
      p.subgroup = nil
      p.save
    end
  end

  # Notify participants of the current subgroups, if any.
  def notify_subgroups!
    ps =
      participants
      .joins(:person)
      .where.not(subgroup: nil)

    ps.each(&:send_subgroup_notification)
  end

  # @return [Activity] the Activity that will start after this Activity. `nil` if no such Activity exists.
  def next_in_group
    group.activities
         .where('start > ?', start)
         .order(start: :asc)
         .first
  end

  # @return [Activity] the Activity that started before this Activity. `nil` if no such Activity exists.
  def previous_in_group
    group.activities
         .where('start < ?', start)
         .order(start: :desc)
         .first
  end

  private

  # Assert that the deadline for participants to change the deadline, if any,
  # is set before the event starts.
  def deadline_before_start
    errors.add(:deadline, I18n.t('activities.errors.must_be_before_start')) if deadline > start
  end

  # Assert that the activity's end, if any, occurs after the event's start.
  def end_after_start
    errors.add(:end, I18n.t('activities.errors.must_be_after_start')) if self.end < start
  end

  # Assert that the reminder for non-response is sent while participants still
  # can change their response.
  def reminder_before_deadline
    errors.add(:reminder_at, I18n.t('activities.errors.must_be_before_deadline')) if reminder_at > deadline
  end

  # Assert that there is at least one divisible subgroup.
  def subgroups_for_division_present
    errors.add(:subgroup_division_enabled, I18n.t('activities.errors.cannot_divide_without_subgroups')) if subgroups.where(is_assignable: true).none? && subgroup_division_enabled?
  end
end
