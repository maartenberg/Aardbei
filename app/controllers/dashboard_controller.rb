class DashboardController < ApplicationController
  before_action :require_login!

  def home
    @upcoming = current_person
      .participants
      .joins(:activity)
      .where('activities.start >= ?', DateTime.now)
      .order('activities.start ASC')
      .paginate(page: params[:upage], per_page: 10)
    @user_organized = @upcoming
      .where(is_organizer: true)
      .limit(3)
    @need_response = @upcoming
      .where(attending: nil)
      .paginate(page: params[:nrpage], per_page: 5)
  end

  def settings
    @person = current_person
    @send_attendance_reminder = @person.send_attendance_reminder
  end

  def update_email_settings
    p = current_person
    p.send_attendance_reminder = params[:send_attendance_reminder]
    p.save

    flash_message(:success, t('settings.saved'))
    redirect_to root_path
  end
end
