module ActivitiesHelper
  def require_organizer!
    return if @activity.may_change?(current_person)

    flash_message(:danger, I18n.t('authentication.organizer_required'))
    redirect_to group_activity_path(@group, @activity)
  end
end
