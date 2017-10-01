class CreateSubgroups < ActiveRecord::Migration[5.0]
  def change
    create_table :subgroups do |t|
      t.references :activity, foreign_key: true
      t.string :name, null: false
      t.boolean :is_assignable

      t.timestamps
    end
  end
end
