class PagesController < ApplicationController
  layout "application"

  def index
    # logic for index
  end

  def show
    # logic for show
  end

  def sc24
    @og_image = "SC24-01.jpeg"
    @page_title = "Ryan @ SC24"
  end

  def sc23
    @og_image = "SC23-06.jpeg"
    @page_title = "Ryan @ SC23"
  end

  def resume
    @page_title = "Ryan's Resume"
  end

  def web
    @page_title = "Ryan's Site Info"
  end

end
