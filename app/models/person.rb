# A person represents a human being. A Person may be a Member in one or more
# Groups, and be a Participant in any number of events of those Groups.
# A Person may access the system by creating a User, and may have at most one
# User.
class Person < ApplicationRecord
  include Rails.application.routes.url_helpers
  # @!attribute first_name
  #   @return [String]
  #     the person's first name. ('Vincent' in 'Vincent van Gogh'.)
  #
  # @!attribute infix
  #   @return [String]
  #     the part of a person's surname that is not taken into account when
  #     sorting by surname. ('van' in 'Vincent van Gogh'.)
  #
  # @!attribute last_name
  #   @return [String]
  #     the person's surname. ('Gogh' in 'Vincent van Gogh'.)
  #
  # @!attribute birth_date
  #   @return [Date]
  #     the person's birth date.
  #
  # @!attribute email
  #   @return [String]
  #     the person's email address.
  #
  # @!attribute calendar_token
  #   @return [String]
  #     the calendar token that can be used to open this Person's events as an
  #     ICAL file.
  #
  # @!attribute is_admin
  #   @return [Boolean]
  #     whether or not the person has administrative rights.

  has_one :user
  has_many :members,
           dependent: :destroy
  has_many :participants,
           dependent: :destroy
  has_many :groups, through: :members
  has_many :activities, through: :participants
  has_secure_token :calendar_token

  validates :email, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  validate :birth_date_cannot_be_in_future

  before_validation :not_admin_if_nil
  before_save :update_user_email, if: :email_changed?

  # The person's full name.
  def full_name
    if self.infix&.present?
      [self.first_name, self.infix, self.last_name].join(' ')
    else
      [self.first_name, self.last_name].join(' ')
    end
  end

  # The person's reversed name, to sort by surname.
  def reversed_name
    if self.infix
      [self.last_name, self.infix, self.first_name].join(', ')
    else
      [self.last_name, self.first_name].join(', ')
    end
  end

  # All activities where this person is an organizer.
  def organized_activities
    self.participants.includes(:activity).where(is_organizer: true)
  end

  # Create multiple Persons from data found in a csv file, return those.
  def self.from_csv(content)
    reader = CSV.parse(content, {headers: true, skip_blanks: true})

    result = []
    reader.each do |row|
      p = Person.find_by(email: row['email'])
      if not p
        p = Person.new
        p.first_name  = row['first_name']
        p.infix       = row['infix']
        p.last_name   = row['last_name']
        p.email       = row['email']
        p.birth_date  = Date.strptime(row['birth_date']) unless row['birth_date'].blank?
        p.save!
      end
      result << p
    end

    return result
  end

  # @return [String]
  #   the URL to access this person's calendar.
  def calendar_url
    person_calendar_url self.calendar_token
  end

  # @return [Icalendar::Calendar]
  #   this Person's upcoming activities feed.
  def calendar_feed(skip_absent = false)
    cal = Icalendar::Calendar.new
    cal.x_wr_calname = 'Aardbei'

    tzid = 1.seconds.since.time_zone.tzinfo.name

    selection = self
      .participants
      .joins(:activity)
      .where('"end" > ?', 3.months.ago)

    if skip_absent
      selection = selection
        .where.not(attending: false)
    end

    selection.each do |p|
      a = p.activity

      description_items = []
      # The description consists of the following parts:
      #  - The Participant's response and notes (if set),
      #  - The Activity's description (if not empty),
      #  - The names of the organizers,
      #  - Subgroup information, if applicable,
      #  - The URL.

      # Response
      yourresponse = "#{I18n.t 'activities.participant.yourresponse'}: #{p.human_attending}"

      if p.notes.present?
        yourresponse << " (#{p.notes})"
      end

      description_items << yourresponse

      # Description
      description_items << a.description if a.description.present?

      # Organizers
      orgi = a.organizer_names
      orgi_names = orgi.join ', '
      orgi_line = case orgi.count
                  when 0 then I18n.t 'activities.organizers.no_organizers'
                  when 1 then "#{I18n.t 'activities.organizers.one'}: #{orgi_names}"
                  else "#{I18n.t 'activities.organizers.other'}: #{orgi_names}"
                  end

      description_items << orgi_line

      # Subgroups
      if a.subgroups.any?
        if p.subgroup
          description_items << "#{I18n.t 'activities.participant.yoursubgroup'}: #{p.subgroup}"
        end

        subgroup_names = a.subgroups.map(&:name).join ', '
        description_items << "#{I18n.t 'activerecord.models.subgroup.other'}: #{subgroup_names}"

      end

      # URL
      a_url = group_activity_url a.group, a
      description_items << a_url

      cal.event do |e|
        e.uid = a_url
        e.dtstart = Icalendar::Values::DateTime.new a.start, tzid: tzid
        e.dtend =   Icalendar::Values::DateTime.new a.end,   tzid: tzid

        e.status = p.ical_attending

        e.summary = a.name
        e.location = a.location

        e.description = description_items.join "\n"

        e.url = a_url
      end
    end

    cal.publish
    cal
  end

  private

  # Assert that the person's birth date, if any, lies in the past.
  def birth_date_cannot_be_in_future
    if self.birth_date && self.birth_date > Date.today
      errors.add(:birth_date, I18n.t('person.errors.cannot_future'))
    end
  end

  # Explicitly force nil to false in the admin field.
  def not_admin_if_nil
    self.is_admin ||= false
  end

  # Ensure the person's user email is updated at the same time as the person's
  # email.
  def update_user_email
    if not self.user.nil?
      self.user.update!(email: self.email)
    end
  end
end
