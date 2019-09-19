class DisallowNilIsOrganizer < ActiveRecord::Migration[5.0]
  def change
    change_column_default :participants, :is_organizer, from: nil, to: false
    change_column_null :participants, :is_organizer, null: false, default: false
  end
end
