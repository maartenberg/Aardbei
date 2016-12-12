class AuthenticationController < ApplicationController
  def login_form
    render layout: 'void'
  end

  def login
    flash[:danger] = "Not yet implemented."
    redirect_to action: 'login_form'
  end

  def create_password_form
    render layout: 'void'
  end

  def create_password
    flash[:danger] = "Not yet implemented."
    redirect_to action: 'login'
  end

  def forgotten_password_form
    render layout: 'void'
  end

  def forgotten_password
    flash[:danger] = "Not yet implemented."
    redirect_to action: 'login'
  end
end
