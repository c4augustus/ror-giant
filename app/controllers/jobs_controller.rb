class JobsController < ApplicationController
  before_action :set_job, only: [:application, :referral]

  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Rails.application.jobs_facility.refresh_jobs
  end

  # GET /jobs/1/application
  def application
    @application = JobApplication.new
  end

  # POST /jobs/1/apply
  def apply
    redirect_to jobs_path
  end

  # GET /jobs/1/referral
  def referral
    @referral = JobReferral.new
  end

  # POST /jobs/1/refer
  def refer
    redirect_to jobs_path
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Job.new(job_params)

    respond_to do |format|
      if @job.save
        format.html { redirect_to @job, notice: 'Job was successfully created.' }
        format.json { render action: 'show', status: :created, location: @job }
      else
        format.html { render action: 'new' }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_url }
      format.json { head :no_content }
    end
  end

  private
    def set_job
      @job = Job.find(params[:job_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:title, :identification, :location, :work_schedule, :start_date, :pay_rate, :description)
    end
end
