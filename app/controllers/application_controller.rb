class ApplicationController < ActionController::Base
  layout "application"

  before_action :set_default_og_image

  private

  def set_default_og_image
    @og_image = 'Profile-01.jpg'
  end
end
