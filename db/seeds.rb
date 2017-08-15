# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'byebug'

p = Person.create!(
  first_name: 'Maarten',
  infix: 'van den',
  last_name: 'Berg',
  birth_date: (Faker::Date.between(21.years.ago, Date.today)),
  email: 'maarten@maartenberg.nl',
  is_admin: true
)

u = User.create!(
  email: 'maarten@maartenberg.nl',
  person: p,
  password: 'aardbei123',
  password_confirmation: 'aardbei123'
)

p2 = Person.create!(
  first_name: 'Henkie',
  last_name: 'Gekke',
  birth_date: (Faker::Date.between(21.years.ago, Date.today)),
  email: 'gekkehenkie@maartenberg.nl'
)

g = Group.create!(
  name: 'Teststam'
)


2.times do |i|
  gr = Group.create!(
    name: Faker::Team.name
  )
end

15.times do |i|
  person = Person.create!(
    first_name: (Faker::Name.first_name),
    last_name:  (Faker::Name.last_name),
    birth_date: (Faker::Date.between(21.years.ago, Date.today)),
    email: "testuser#{i}@maartenberg.nl"
  )
end

a = Activity.create!(
  public_name: 'Fikkie stoken ofzo',
  description: 'Een scout trekt er samen met anderen op uit',
  location: 'In het bos in het bos',
  start: 4.weeks.since,
  end: 4.weeks.since + 2.hours,
  deadline: 3.weeks.since,
  group: g
)

Group.all.each do |g|
  10.times do |i|
    starttime = Faker::Time.between(DateTime.now, 1.years.since, :morning)
    endtime   = Faker::Time.between(1.hours.since(starttime), 1.days.since(starttime), :afternoon)
    deadline  = 5.days.ago(starttime)

    act = Activity.create!(
      public_name: Faker::Hacker.ingverb,
      description: Faker::Hipster.sentence,
      location: Faker::Address.city,
      start: starttime,
      end: endtime,
      deadline: deadline,
      group: g
    )
  end
end

Person.all.each do |p|
  Group.all.each do |g|
    if Faker::Boolean.boolean(0.75)
      mem = Member.create!(
        person: p,
        group:  g,
        is_leader: Faker::Boolean.boolean(0.1)
      )
      g.activities.each do |a|
        if Faker::Boolean.boolean(0.15)
          notes = Faker::Hipster.sentence
        else
          notes = nil
        end

        # Participants are created on adding to group!
        part = Participant.find_by(
          activity: a,
          person: p
        )
        part.update!(
          is_organizer: Faker::Boolean.boolean(0.1),
          attending: [true, false, nil].sample,
          notes:    notes
        )
      end
    end
  end
end
