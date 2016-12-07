class CreateActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :activities do |t|
      t.string :public_name
      t.string :secret_name
      t.string :description
      t.string :location
      t.datetime :start
      t.datetime :end
      t.datetime :deadline
      t.boolean :show_hidden
      t.references :group, foreign_key: true

      t.timestamps
    end
  end
end
