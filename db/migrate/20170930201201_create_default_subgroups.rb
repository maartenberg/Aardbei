class CreateDefaultSubgroups < ActiveRecord::Migration[5.0]
  def change
    create_table :default_subgroups do |t|
      t.references :group, foreign_key: true
      t.string :name, null: false
      t.boolean :is_assignable

      t.timestamps
    end
  end
end
