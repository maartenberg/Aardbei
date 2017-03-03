module ApplicationHelper
  def flash_message(category, message, **pairs)
    flash[:alerts] ||= {}
    flash[:alerts][category] ||= []
    flash[:alerts][category] << message
  end
end
