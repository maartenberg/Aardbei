class PopulateDisplayNames < ActiveRecord::Migration[5.0]
  def down; end

  def up
    Member.all.each do |m|
      m.update_display_name! if m.display_name.blank?
    end
  end
end
