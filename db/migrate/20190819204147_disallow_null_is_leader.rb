class DisallowNullIsLeader < ActiveRecord::Migration[5.0]
  def change
    change_column_null :members, :is_leader, false, false
    change_column_default :members, :is_leader, from: nil, to: false
  end
end
