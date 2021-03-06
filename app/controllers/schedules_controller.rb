class SchedulesController < ApplicationController
  before_action :set_schedule, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :check_schedule_owner, only: [:edit, :update, :destory]
  # GET /schedules
  # GET /schedules.json
  def index
    @users = User.most_studies_users
    @schedules = Schedule.this_week_studytime_sorted
    @portfolios = Portfolio.includes(:tags, comments: [:user]).limit(6)
    @books = Book.order(created_at: :desc)
    @articles = Article.order(created_at: :desc).limit(6)
  end

  # GET /schedules/new
  def new
    @schedule = Schedule.new
  end

  # GET /schedules/1/edit
  def edit
  end

  # POST /schedules
  # POST /schedules.json
  def create
    @schedule = current_user.schedules.new(schedule_params)

    respond_to do |format|
      if @schedule.save
        format.html { redirect_to dashboard_path, notice: 'Schedule was successfully created.' }
        format.json { render :show, status: :created, location: @schedule }
      else
        format.html { render :new }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /schedules/1
  # PATCH/PUT /schedules/1.json
  def update
    respond_to do |format|
      if @schedule.update(schedule_params)
        format.html { redirect_to dashboard_path, notice: 'Schedule was successfully updated.' }
        format.json { render :show, status: :ok, location: @schedule }
      else
        format.html { render :edit }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schedules/1
  # DELETE /schedules/1.json
  def destroy
    @schedule.destroy
    respond_to do |format|
      format.html { redirect_to schedules_url, notice: 'Schedule was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def dashboard
    @schedules = current_user.schedules.includes(:study_language)
    @all_schedules = current_user.schedules.includes(:study_language).order(starttime: :desc)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_schedule
      @schedule = Schedule.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def schedule_params
      params.require(:schedule).permit(:title, :memo, :starttime, :endtime, :study_language_id)
    end

    def check_schedule_owner
      redirect_to root_path, notice: '権限がありません' unless @schedule.user == current_user
    end
end
