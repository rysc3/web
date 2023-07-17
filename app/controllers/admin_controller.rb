# require 'rotp'
class AdminController < ApplicationController
  before_action :authenticate!

  def index
    if session[:ver]
      # render admin view 
    else 
      # render request for verification 
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


  end
end
