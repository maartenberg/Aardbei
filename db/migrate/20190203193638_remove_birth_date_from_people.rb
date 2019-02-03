class RemoveBirthDateFromPeople < ActiveRecord::Migration[5.0]
  def change
    remove_column :people, :birth_date, :date
  end
end
