class CreateMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :members do |t|
      t.references :person, foreign_key: true
      t.references :group, foreign_key: true
      t.boolean :is_leader

      t.timestamps
    end
  end
end
