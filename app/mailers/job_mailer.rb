class JobMailer < ActionMailer::Base
  #default from: "from@example.com"

  def email_address_for_resumes
    "resumes@#{default_url_options[:host]}"
  end

  def mail_application(job_application)
    @job_application = job_application
    @job = @job_application.job
    @url = url_to_job
    @subject = "Application for #{reference_to_job}, by #{@job_application.name}"
    if @job_application.attachment_resume
      attachments['resume'] = @job_application.attachment_resume.read
    end
    if @job_application.attachment_portfolio
      attachments['portfolio']  = @job_application.attachment_portfolio.read
    end
    mail from: @job_application.email,
           to: email_address_for_resumes,
           cc: @job_application.email,
      subject: @subject
  end

  def mail_referral(job_referral)
    @job_referral = job_referral
    @job = @job_referral.job
    @job_reference = reference_to_job
    @url = url_to_job
    @subject = "#{@job_referral.name} wants to you know about #{reference_to_job}"
    mail from: email_address_for_resumes,
           to: @job_referral.email,
           cc: email_address_for_resumes,
      subject: @subject
  end

private
  def reference_to_job
     "Giant Recruiting job ##{@job.id_scheme_ext}: \"#{@job.title}\""
  end

  def url_to_job
    url_for(controller: 'jobs',
                action: 'index',
             only_path: false) <<
      "##{@job.id_scheme_ext}"
  end
end
