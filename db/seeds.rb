# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

exit if Rails.env.production?

its_me = Person.create!(
  first_name: 'Maarten',
  infix: 'van den',
  last_name: 'Berg',
  email: 'maarten@maartenberg.nl',
  is_admin: true
)

User.create!(
  email: 'maarten@maartenberg.nl',
  person: its_me,
  password: 'aardbei123',
  password_confirmation: 'aardbei123',
  confirmed: true
)

Person.create!(
  first_name: 'Henkie',
  last_name: 'Gekke',
  email: 'gekkehenkie@maartenberg.nl'
)

default_test_group = Group.create!(
  name: 'Teststam'
)

2.times do
  Group.create!(
    name: Faker::Team.name
  )
end

15.times do |i|
  Person.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: "testuser#{i}@maartenberg.nl"
  )
end

Activity.create!(
  name: 'Fikkie stoken ofzo',
  description: 'Een scout trekt er samen met anderen op uit',
  location: 'In het bos in het bos',
  start: 4.weeks.since,
  end: 4.weeks.since + 2.hours,
  deadline: 3.weeks.since,
  group: default_test_group
)

Group.all.each do |g|
  10.times do
    starttime = Faker::Time.between(Time.zone.now, 1.year.since, :morning)
    endtime   = Faker::Time.between(1.hour.since(starttime), 1.day.since(starttime), :afternoon)
    deadline  = 5.days.ago(starttime)

    Activity.create!(
      name: Faker::Hacker.ingverb,
      description: Faker::Hipster.sentence,
      location: Faker::Address.city,
      start: starttime,
      end: endtime,
      deadline: deadline,
      group: g,
      no_response_action: Faker::Boolean.boolean
    )
  end
end

Person.all.each do |p|
  Group.all.each do |g|
    next unless Faker::Boolean.boolean(0.75)

    Member.create!(
      person: p,
      group: g,
      is_leader: Faker::Boolean.boolean(0.1)
    )
    g.activities.each do |a|
      notes = (Faker::Hipster.sentence if Faker::Boolean.boolean(0.15))

      # Participants are created on adding to group, no need to create
      part = Participant.find_by(
        activity: a,
        person: p
      )
      part.update!(
        is_organizer: Faker::Boolean.boolean(0.1),
        attending: [true, false, nil].sample,
        notes: notes
      )
    end
  end
end
