class AsunmController < ApplicationController
  def home
    # render partial: 'asunm/home', layout: 'asunm'
  end

  def personnel
    # render partial: 'asunm/personnel', layout: 'asunm'
    render layout: 'asunm'
  end

  def information
    # render partial: 'asunm/information', layout: 'asunm'
  end
end
