class DashboardController < ApplicationController
  before_action :require_login!

  def home
    @user_organized = current_person.participants.includes(:activity).where(is_organizer: true)
    @need_response = current_person.participants.includes(:activity).where(attending: nil)
    @upcoming = current_person.activities.where('start > ?', DateTime.now).includes(:participants)
    @upcoming = current_person.participants
      .includes(:activity).joins(:activity)
      .where("activities.start >= ?", DateTime.now)
  end
end
