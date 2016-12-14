# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

p = Person.create!(
  first_name: 'Maarten',
  infix: 'van den',
  last_name: 'Berg',
  birth_date: (Date.new 2016, 1, 1),
  email: 'maarten@maartenberg.nl.eu.org',
  is_admin: true
)

p2 = Person.create!(
  first_name: 'Henkie',
  last_name: 'Gekke',
  birth_date: (Date.new 2016, 1, 1),
  email: 'geefmijgeld@maartenberg.nl.eu.org'
)

u = User.create!(
  email: 'maarten@maartenberg.nl.eu.org',
  person: p,
  password: 'damena123',
  password_confirmation: 'damena123'
)

g = Group.create!(
  name: 'Teststam'
)

a = Activity.create!(
  public_name: 'Fikkie stoken ofzo',
  secret_name: 'Bosbrandopkomst',
  description: 'Een scout trekt er samen met anderen op uit',
  location: 'In het bos in het bos',
  start: 4.weeks.since,
  end: 4.weeks.since + 2.hours,
  deadline: 3.weeks.since,
  show_hidden: false,
  group: g
)

Member.create!(
  group: g,
  person: p,
  is_leader: true
)
Member.create!(
  group: g,
  person: p2
)

Participant.create!(
  activity: a,
  person: p,
  is_organizer: true,
  attending: true,
  notes: nil
)
Participant.create!(
  activity: a,
  person: p2,
  is_organizer: false,
  attending: false,
  notes: 'fliep floep'
)
