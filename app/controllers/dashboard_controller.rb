class DashboardController < ApplicationController
  before_action :require_login!

  def home
    @upcoming = current_person
                .participants
                .joins(:activity)
                .where('activities.end >= ? OR (activities.end IS NULL AND activities.start >= ?)', Time.zone.now, Time.zone.now)
                .order('activities.start ASC')
    @user_organized = @upcoming
                      .where(is_organizer: true)
                      .limit(3)
    @upcoming = @upcoming
                .paginate(page: params[:upage], per_page: 10)
    @need_response = @upcoming
                     .where(attending: nil)
                     .paginate(page: params[:nrpage], per_page: 5)
  end

  def set_settings_params!
    @person = current_person
    @send_attendance_reminder = @person.send_attendance_reminder
    @active_sessions = Session.where(user: current_user).where(active: true).where('expires > ?', Time.zone.now).count
  end

  def settings
    set_settings_params!
  end

  def update_email_settings
    p = current_person
    p.send_attendance_reminder = params[:send_attendance_reminder]
    p.save

    flash_message(:success, t('settings.saved'))
    redirect_to root_path
  end

  def logout_all_sessions
    u = current_user

    u.logout_all_sessions!
    log_out

    redirect_to login_path
  end

  def update_password
    u = current_user

    current = params[:current_password]
    new = params[:new_password]
    confirm = params[:new_password_confirm]

    unless u.authenticate(current)
      flash_message(:danger, t('authentication.invalid_pass'))
      redirect_to settings_path
      return
    end

    if new.blank?
      flash_message(:danger, t('authentication.password_blank'))
      redirect_to settings_path
      return
    end

    if new != confirm
      flash_message(:danger, t('authentication.password_repeat_mismatch'))
      redirect_to settings_path
      return
    end

    u.password = new
    u.password_confirmation = confirm
    if u.save
      flash_message(:success, t('authentication.password_changed'))
      u.logout_all_sessions!
      log_out
      redirect_to login_path
      return
    else
      flash_message(:danger, t(:somethingbroke))
      Rails.logger.error('Password change failure')
      redirect_to settings_path
    end
  end
end
