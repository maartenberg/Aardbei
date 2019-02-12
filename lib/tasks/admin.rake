namespace :admin do
  desc "Create a new Admin"
  task :create => [:environment] do
    p = Person.new
    p.is_admin = 1
    puts "Email?"
    p.email = STDIN.gets.chomp
    puts "First name?"
    p.first_name = STDIN.gets.chomp
    puts "Infix?"
    p.infix = STDIN.gets.chomp
    puts "Last name?"
    p.last_name = STDIN.gets.chomp

    puts "Is this information correct? [Y/N]"
    confirm = STDIN.gets.chomp

    unless confirm.upcase.first == "Y"
      puts "Aborting."
      return false
    end

    p.save!

    puts "Saved! You now need to request a password."
  end
end
