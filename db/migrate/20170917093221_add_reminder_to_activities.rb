class AddReminderToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :reminder_at, :datetime
    add_column :activities, :reminder_done, :boolean
  end
end
