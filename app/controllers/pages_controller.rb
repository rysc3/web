class PagesController < ApplicationController
  def home
    @docs = Doc.all
  end

  def resume
  end

  def contact
  end

  def schedule
  end
end
