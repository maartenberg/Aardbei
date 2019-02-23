class PopulateDisplayNames < ActiveRecord::Migration[5.0]
  def down; end

  def up
    Member.all.each do |m|
      if m.display_name.blank?
        m.update_display_name!
      end
    end
  end
end
