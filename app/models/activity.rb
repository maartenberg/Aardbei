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

  belongs_to :group

  has_many :participants,
    dependent: :destroy
  has_many :people, through: :participants

  validates :name, presence: true
  validates :start, presence: true
  validate  :deadline_before_start, unless: "self.deadline.blank?"
  validate  :end_after_start,       unless: "self.end.blank?"

  after_create :create_missing_participants!

  # Get all people (not participants) that are organizers. Does not include
  # group leaders, although they may modify the activity as well.
  def organizers
    self.participants.includes(:person).where(is_organizer: true)
  end

  # Determine whether the passed Person participates in the activity.
  def is_participant?(person)
    Participant.exists?(
      activity_id: self.id,
      person_id: person.id
    )
  end

  # Determine whether the passed Person is an organizer for the activity.
  def is_organizer?(person)
    Participant.exists?(
      person_id: person.id,
      activity_id: self.id,
      is_organizer: true
    )
  end

  # Query the database to determine the amount of participants that are present/absent/unknown
  def state_counts
    self.participants.group(:attending).count
  end

  # Return participants attending, absent, unknown
  def human_state_counts
    c = self.state_counts
    p = c[true]
    a = c[false]
    u = c[nil]
    return "#{p or 0}, #{a or 0}, #{u or 0}"
  end

  # Determine whether the passed Person may change this activity.
  def may_change?(person)
    person.is_admin ||
    self.is_organizer?(person) ||
    self.group.is_leader?(person)
  end

  # Create Participants for all People that
  #  1. are members of the group
  #  2. do not have Participants (and thus, no way to confirm) yet
  def create_missing_participants!
    people = self.group.people
    if not self.participants.empty?
      people = people.where('people.id NOT IN (?)', self.people.ids)
    end

    people.each do |p|
      Participant.create(
        activity: self,
        person: p,
      )
    end
  end

  # Create multiple Activities from data in a CSV file, assign to a group, return.
  def self.from_csv(content, group)
    reader = CSV.parse(content, {headers: true, skip_blanks: true})

    result = []
    reader.each do |row|
      a = Activity.new
      a.group       = group
      a.name        = row['name']
      a.description = row['description']
      a.location    = row['location']

      sd            = Date.strptime(row['start_date'])
      st            = Time.strptime(row['start_time'], '%H:%M')
      a.start       = Time.zone.local(sd.year, sd.month, sd.day, st.hour, st.min)

      if not row['end_date'].blank?
        ed          = Date.strptime(row['end_date'])
        et          = Time.strptime(row['end_time'], '%H:%M')
        a.end       = Time.zone.local(ed.year, ed.month, ed.day, et.hour, et.min)
      end

      dd            = Date.strptime(row['deadline_date'])
      dt            = Time.strptime(row['deadline_time'], '%H:%M')
      a.deadline    = Time.zone.local(dd.year, dd.month, dd.day, dt.hour, dt.min)

      result << a
    end

    result
  end

  # Send a reminder to all participants who haven't responded, and set their
  # response to 'attending'.
  def send_reminder
    # Sanity check that the reminder date didn't change while queued.
    return unless !self.reminder_done && self.reminder_at
    return if self.reminder_at > Time.zone.now

    participants = self.participants.where(attending: nil)
    participants.each { |p| p.send_reminder }
  end

  private
  # Assert that the deadline for participants to change the deadline, if any,
  # is set before the event starts.
  def deadline_before_start
    if self.deadline > self.start
      errors.add(:deadline, I18n.t('activities.errors.must_be_before_start'))
    end
  end

  # Assert that the activity's end, if any, occurs after the event's start.
  def end_after_start
    if self.end < self.start
      errors.add(:end, I18n.t('activities.errors.must_be_after_start'))
    end
  end
end
