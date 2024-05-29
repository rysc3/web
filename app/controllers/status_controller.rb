class StatusController < ApplicationController
  before_action :set_status, only: [:show, :edit, :update, :destroy]

  def index
    @statuses = Status.all
  end

  def show
  end

  def new
    @status = Status.new
  end

  def create
    @status = Status.new(status_params)
    if @status.save
      redirect_to @status, notice: 'Status was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @status.update(status_params)
      redirect_to @status, notice: 'Status was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @status.destroy
    redirect_to statuses_url, notice: 'Status was successfully destroyed.'
  end

  private
    def set_status
      @status = Status.find(params[:id])
    end

    def status_params
      params.require(:status).permit(:attribute1, :attribute2, :attribute3)
    end
end
