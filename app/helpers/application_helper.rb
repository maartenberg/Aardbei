module ApplicationHelper
  def flash_message(category, message)
    flash[:alerts] ||= {}
    flash[:alerts][category] ||= []
    flash[:alerts][category] << message
  end
end
