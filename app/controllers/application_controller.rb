class ApplicationController < ActionController::Base
  layout "application"

  before_action :set_default_og_image
  before_action :set_default_page_title

  private

  def set_default_og_image
    # Original
    # @og_image = 'Profile-01.jpg'

    # New one
    @og_image = 'Profile-05.jpg'
  end

  def set_default_page_title
    @page_title = "Ryan's Website"
  end
end
