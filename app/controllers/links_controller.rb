class LinksController < ApplicationController

  def index
    @links = Link.all
  end

  def show
    @link = Link.find_by(id: params[:id])
  end
end
