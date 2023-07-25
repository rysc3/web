class DocsController < ApplicationController
  before_action :set_doc, only: [:show]

  def index 
    @docs = Doc.all
  end

  def show 
    @docs = Doc.where(id: params[:id])
  end

  
  private 
    def doc_params
      params.require(:doc).permit(:title, :content)
    end

    def set_doc
      @doc = Doc.find(params[:id])
    end
end