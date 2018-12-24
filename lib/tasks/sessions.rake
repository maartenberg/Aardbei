namespace :sessions do
  desc "Clean all expired sessions from the database"
  task clean: :environment do
    expired = Session.where('sessions.expires < ?', Time.zone.now)
    deactivated = Session.where(active: false)
    puts "Cleaning #{expired.count} expired, #{deactivated.count} deactivated sessions."
    expired.destroy_all
    deactivated.destroy_all
  end
end
