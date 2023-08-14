require 'rotp'
class AdminController < ApplicationController
  before_action :authenticate!

  def index
    if session[:ver]
      # Render admin view
    else
      render 'google_authenticator/setup'
    end
  end

  def verify
    totp = ROTP::TOTP.new(params[:secret])
    valid_code = totp.verify(params[:code])

    if valid_code
      session[:ver] = true
      redirect_to admin_path, notice: 'Verification successful'
    else
      redirect_to admin_path, alert: 'Invalid verification code'
    end
  end

  private

  def authenticate!
    # Check if the session token is present
    # if session[:ver].nil?
    #   # redirect_to setup_path, alert: 'Please complete Google Authenticator setup'
    # end
    
  end
end
