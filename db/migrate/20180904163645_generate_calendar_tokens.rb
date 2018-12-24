class GenerateCalendarTokens < ActiveRecord::Migration[5.0]
  def up
    Person.all.each(&:regenerate_calendar_token)
  end

  def down; end
end
