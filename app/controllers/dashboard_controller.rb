class DashboardController < ApplicationController
  before_action :require_login!

  def home
    @upcoming = current_person
      .participants
      .joins(:activity)
      .where('activities.start >= ?', DateTime.now)
      .order('activities.start ASC')
    @user_organized = @upcoming
      .where(is_organizer: true)
    @need_response = @upcoming
      .where(attending: nil)
  end
end
