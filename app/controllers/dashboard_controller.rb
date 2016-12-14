class DashboardController < ApplicationController
  before_action :require_login!

  def home
    @user_organized = current_person.activities.where(is_organizer: true)
    @need_response = current_person.activities.includes(:participants)
  end
end
