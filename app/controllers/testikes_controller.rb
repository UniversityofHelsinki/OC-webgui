class TestikesController < ApplicationController
  before_action :set_testike, only: [:show, :edit, :update, :destroy]

  # GET /testikes
  # GET /testikes.json
  def index
    @testikes = Testike.all
  end

  # GET /testikes/1
  # GET /testikes/1.json
  def show
  end

  # GET /testikes/new
  def new
    @testike = Testike.new
  end

  # GET /testikes/1/edit
  def edit
  end

  # POST /testikes
  # POST /testikes.json
  def create
    @testike = Testike.new(testike_params)

    respond_to do |format|
      if @testike.save
        format.html { redirect_to @testike, notice: 'Testike was successfully created.' }
        format.json { render :show, status: :created, location: @testike }
      else
        format.html { render :new }
        format.json { render json: @testike.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /testikes/1
  # PATCH/PUT /testikes/1.json
  def update
    respond_to do |format|
      if @testike.update(testike_params)
        format.html { redirect_to @testike, notice: 'Testike was successfully updated.' }
        format.json { render :show, status: :ok, location: @testike }
      else
        format.html { render :edit }
        format.json { render json: @testike.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /testikes/1
  # DELETE /testikes/1.json
  def destroy
    @testike.destroy
    respond_to do |format|
      format.html { redirect_to testikes_url, notice: 'Testike was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_testike
      @testike = Testike.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def testike_params
      params.require(:testike).permit(:asd)
    end
end
