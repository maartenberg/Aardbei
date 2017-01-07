module DashboardHelper
  def xeditable? obj = nil
    obj.activity.may_change? current_person
    true
  end
end
