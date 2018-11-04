# Generate an API token for each group after adding the column.
class GenerateGroupApiTokens < ActiveRecord::Migration[5.0]
  def up
    Group.all.each(&:regenerate_api_token)
  end

  # No-op
  def down; end
end