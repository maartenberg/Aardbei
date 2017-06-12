module GroupsHelper
  def require_membership!
    require_login!
    if !(@group.is_member?(current_person) || current_person.is_admin?)
      flash_message(:danger, "You need to be a member of that group to do that.")
      redirect_to dashboard_home_path
    end
  end

  def require_leader!
    require_login!

    if !(@group.is_leader?(current_person) ||
         current_person.is_admin?)
      flash_message(:danger, "You need to be a group leader to do that.")
      redirect_to dashboard_home_path
    end
  end
end
