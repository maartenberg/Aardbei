module GroupsHelper
  def require_membership!
    require_login!
    if !(Member.exists?(group: @group, person: current_person) || current_person.is_admin?)
      flash_message(:danger, "You need to be a member of that group to do that.")
      redirect_to dashboard_url
    end
  end

  def require_leader!
    require_login!

    if !(Member.exists?(group: @group, is_leader: true, person: current_person) ||
         current_person.is_admin?)
      flash_message(:danger, "You need to be a group leader to do that.")
      redirect_to dashboard_url
    end
  end
end
