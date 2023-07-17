class GoogleAuthenticatorController < ApplicationController
  def setup
    @qr_code_url = current_user.otp_qr_code_url
    @secret = current_user.otp_secret
  end
end
