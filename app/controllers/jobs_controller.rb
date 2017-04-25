class JobsController < ApplicationController
  before_action :set_job, only: [:jobapp, :jobapply, :referral, :refer]
  respond_to :html, :js

  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Rails.application.jobs_facility.refresh_jobs(category: params[:category])
  end

  # GET /jobs/1/jobapp
  def jobapp
    @jobapp = JobApplication.new
  end

  # POST /jobs/1/jobapply
  def jobapply
    if params[:commit].eql?('SEND')
      if @job
        if (job_application = @job.apply(params.require(:job_application).permit!))
          AppMailer.mail_application(job_application).deliver
        end
      end
    end
  end

  # GET /jobs/1/referral
  def referral
    @referral = JobReferral.new
  end

  # POST /jobs/1/refer
  def refer
    if params[:commit].eql?('SEND')
      if @job
        if (job_referral = @job.refer(params.require(:job_referral).permit!))
          AppMailer.mail_referral(job_referral).deliver
        end
      end
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
