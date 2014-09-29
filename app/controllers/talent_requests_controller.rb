class TalentRequestsController < ApplicationController
  def new
    @talent_request = TalentRequest.new
  end

  def create
    if (talent_request = TalentRequest.create(params.require(:talent_request).permit!))
      AppMailer.mail_talent_request(talent_request).deliver
    end
    redirect_to root_path
  end
end
