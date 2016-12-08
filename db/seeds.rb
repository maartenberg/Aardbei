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

u = User.create!(
  email: 'maarten@maartenberg.nl.eu.org',
  person: p,
  password: 'damena123',
  password_confirmation: 'damena123'
)
