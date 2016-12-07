class CreateParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :participants do |t|
      t.references :person, foreign_key: true
      t.references :activity, foreign_key: true
      t.boolean :is_organizer
      t.boolean :attending
      t.text :notes

      t.timestamps
    end
  end
end
