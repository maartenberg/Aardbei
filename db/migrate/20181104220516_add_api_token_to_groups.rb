class AddApiTokenToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :api_token, :string
    add_index :groups, :api_token, unique: true
  end
end
