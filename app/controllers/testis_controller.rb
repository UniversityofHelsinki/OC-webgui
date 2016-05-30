class TestisController < ApplicationController
  before_action :set_testis, only: [:show, :edit, :update, :destroy]

  # GET /testis
  # GET /testis.json
  def index
    @testis = Testi.all
  end

  # GET /testis/1
  # GET /testis/1.json
  def show
  end

  # GET /testis/new
  def new
    @testis = Testi.new
  end

  # GET /testis/1/edit
  def edit
  end

  # POST /testis
  # POST /testis.json
  def create
    @testis = Testi.new(testis_params)

    respond_to do |format|
      if @testis.save
        format.html { redirect_to @testis, notice: 'Testi was successfully created.' }
        format.json { render :show, status: :created, location: @testis }
      else
        format.html { render :new }
        format.json { render json: @testis.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /testis/1
  # PATCH/PUT /testis/1.json
  def update
    respond_to do |format|
      if @testis.update(testis_params)
        format.html { redirect_to @testis, notice: 'Testi was successfully updated.' }
        format.json { render :show, status: :ok, location: @testis }
      else
        format.html { render :edit }
        format.json { render json: @testis.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /testis/1
  # DELETE /testis/1.json
  def destroy
    @testis.destroy
    respond_to do |format|
      format.html { redirect_to testis_url, notice: 'Testi was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_testis
    @testis = Testi.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def testis_params
    params.require(:testis).permit(:name, :city, :age)
  end
end
