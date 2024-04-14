class PagesController < ApplicationController
  def index
    @links = Link.all
  end

  def contact
  end

  def courses
  end
end
