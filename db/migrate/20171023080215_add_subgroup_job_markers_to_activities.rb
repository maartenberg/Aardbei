class AddSubgroupJobMarkersToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :subgroup_division_enabled, :boolean
    add_column :activities, :subgroup_division_done, :boolean
  end
end
