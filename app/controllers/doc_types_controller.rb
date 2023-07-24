class DocTypesController < ApplicationController 
  before_action :set_doc_type 

    # GET /docs/1/edit
    def edit
    end

    def update 
      respond_to do |format|
        if @doc_type.update(doc_type_params)
          format.html { redirect_to docs_path, notice: "Doc type was successfully updated." }
          format.json { render :show, status: :ok, location: @doc_type }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @doc_type.errors, status: :unprocessable_entity }
        end
      end
    end

  private 
    def set_doc_type 
      @doc_type = DocType.find(params[:id])
    end

    def doc_type_params 
      params.require(:doc_type).permit(:name)
    end 
end