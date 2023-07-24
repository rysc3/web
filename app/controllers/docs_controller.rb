class DocsController < ApplicationController
  before_action :set_doc_type
  before_action :set_doc, only: %i[ show edit update destroy ]

  # GET /docs or /docs.json
  def index
    @docs = Doc.all
  end

  # GET /docs/1 or /docs/1.json
  def show
    @doc = Doc.find(params[:id])
  end

  # GET /docs/new
  def new
    @doc = Doc.new
  end

  # GET /docs/1/edit
  def edit
    redirect_to edit_doc_type_path(@doc.doc_type)
  end

  # POST /docs or /docs.json
  def create
    @doc = Doc.new(doc_params)

    respond_to do |format|
      if @doc.save
        format.html { redirect_to doc_url(@doc), notice: "Doc was successfully created." }
        format.json { render :show, status: :created, location: @doc }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @doc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /docs/1 or /docs/1.json
  def update
    respond_to do |format|
      if @doc.update(doc_params)
        format.html { redirect_to doc_url(@doc), notice: "Doc was successfully updated." }
        format.json { render :show, status: :ok, location: @doc }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @doc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /docs/1 or /docs/1.json
  def destroy
    @doc.destroy

    respond_to do |format|
      format.html { redirect_to docs_url, notice: "Doc was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_doc
      @doc = Doc.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def doc_params
      params.require(:doc).permit(:title, :content)
    end

    def set_doc_type 
      # @doc_type = DocType.find(params[:doc_type_id])
    end
end
