class TalentRequestsController < ApplicationController
  def new
    @talent_request = TalentRequest.new
  end

  def create
=begin @@@ FUTURE WORK
    @talent_request = TalentRequest.new(params.require(:talent_request).permit!))
    respond_to do |format|
      if @job.save
        format.html { redirect_to @job, notice: 'Job was successfully created.' }
        format.json { render action: 'show', status: :created, location: @job }
      else
        format.html { render action: 'new' }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
    respond_with
=end
    if (talent_request = TalentRequest.create(params.require(:talent_request).permit!))
      AppMailer.mail_talent_request(talent_request).deliver
    end
    redirect_to root_path
  end
end
