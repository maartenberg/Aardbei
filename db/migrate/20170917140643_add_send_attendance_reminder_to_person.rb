class AddSendAttendanceReminderToPerson < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :send_attendance_reminder, :boolean, default: true
  end
end
