class AuthenticationController < ApplicationController
  def login_form
    render layout: 'void'
  end

  def login
    if params[:session][:email].blank? || params[:session][:password].blank?
      flash[:warning] = "You forgot to add value"
    else
      u = User.find_by(email: params[:session][:email])

      if u && u.authenticate(params[:session][:password])
        # TODO Login logic here
        flash[:success] = "Hello, #{u.person.full_name}!"
      else
        flash[:danger] = "Invalid username/password combination!"
      end
    end

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
