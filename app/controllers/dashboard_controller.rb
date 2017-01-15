class DashboardController < ApplicationController
  before_action :require_login!

  def home
    @user_organized = current_person
      .participants
      .joins(:activity)
      .where(is_organizer: true)
      .order('activities.start ASC')
    @need_response = current_person
      .participants
      .joins(:activity)
      .where(attending: nil)
      .order('activities.start ASC')
    @upcoming = current_person
      .participants
      .joins(:activity)
      .where('activities.start >= ?', DateTime.now)
      .order('activities.start ASC')
  end
end
