class AuthenticationController < ApplicationController
  def login_form
    render layout: 'void'
  end

  def login
    if params[:session][:email].blank? || params[:session][:password].blank?
      flash[:warning] = "You forgot to add value"
      redirect_to action: 'login_form'
    else
      u = User.find_by(email: params[:session][:email])

      if u && u.authenticate(params[:session][:password])
        log_in(u, params[:session][:remember_me].to_i)

        flash[:success] = "Hello, #{u.person.full_name}!"
        redirect_to dashboard_home_path
      else
        flash[:danger] = "Invalid username/password combination!"
        redirect_to action: 'login_form'
      end
    end
  end

  def logout_form
    render layout: 'void'
  end

  def logout
    log_out
    redirect_to login_path
  end

  def create_password_form
    render layout: 'void'
  end

  def login_status
    render text: is_logged_in?
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

  private
  def session_params
    params.require(:session).permit(:email, :password, :remember_me)
  end
end
