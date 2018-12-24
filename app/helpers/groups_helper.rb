module GroupsHelper
  def require_membership!
    return unless require_login!

    return if @group.is_member?(current_person) || current_person.is_admin?

    flash_message(:danger, I18n.t('groups.membership_required'))
    redirect_to dashboard_home_path
  end

  def require_leader!
    return unless require_login!

    return if @group.is_leader?(current_person) || current_person.is_admin?

    flash_message(:danger, I18n.t('groups.leadership_required'))
    redirect_to dashboard_home_path
  end
end
