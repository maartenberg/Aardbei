class GenerateCalendarTokens < ActiveRecord::Migration[5.0]
  def up
    Person.all.each do |p|
      p.regenerate_calendar_token
    end
  end

  def down
  end
end
