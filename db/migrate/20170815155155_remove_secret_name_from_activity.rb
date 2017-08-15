class RemoveSecretNameFromActivity < ActiveRecord::Migration[5.0]
  def up
    remove_column :activities, :secret_name
    remove_column :activities, :show_hidden
    rename_column :activities, :public_name, :name
  end

  def down
    rename_column :activities, :name, :public_name
    add_column :activities, :secret_name, :string
    add_column :activities, :show_hidden, :boolean
  end
end
