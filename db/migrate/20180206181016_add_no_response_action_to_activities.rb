class AddNoResponseActionToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :no_response_action, :boolean, default: true
  end
end
