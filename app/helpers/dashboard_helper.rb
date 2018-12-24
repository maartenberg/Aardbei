module DashboardHelper
  def xeditable?(obj = nil)
    obj.may_change?(current_person)
  end
end
