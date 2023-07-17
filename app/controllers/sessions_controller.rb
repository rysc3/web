class SessionsController < ApplicationController
  def new
    # Render the login form
  end

  def create
    user = User.find_by(username: params[:username])
    if user&.authenticate(params[:password])
      # Successful authentication
      log_in(user)  # Implement the logic to log in the user
      redirect_to root_path, notice: "Logged in successfully."
    else
      # Failed authentication
      flash.now[:alert] = "Invalid username or password."
      render :new
    end
  end

  def destroy
    log_out  # Implement the logic to log out the user
    redirect_to root_path, notice: "Logged out successfully."
  end
end
