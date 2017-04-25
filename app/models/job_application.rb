class JobApplication
  include Mongoid::Document
  belongs_to :job
  field :name_first,                    type: String
  field :name_last,                     type: String
  field :email,                         type: String
  field :phone,                         type: String
  field :date_start_available,          type: Date
  field :status_employment_current,     type: String
  field :status_authorization_to_work,  type: String
  field :link_to_portfolio,             type: String
  field :link_to_resume,                type: String
  field :attachment_filename_resume,    type: String

  attr_accessor :attachment_resume, :attachment_portfolio

  def self.build(attributes)
    if (attachment_resume = attributes['attachment_resume'])
      attributes['attachment_filename_resume'] =
        attachment_resume.original_filename
      attributes.delete('attachment_resume')
    end
    if (attachment_portfolio = attributes['attachment_portfolio'])
      attributes['attachment_filename_portfolio'] =
        attachment_portfolio.original_filename
      attributes.delete('attachment_portfolio')
    end
    JobApplication.create(attributes).tap do |obj|
      obj.attachment_resume    = attachment_resume
      obj.attachment_portfolio = attachment_portfolio
    end
  end

  def name
    name_first.empty? ? name_last :
      (name_first + (name_last.empty? ? "" :
                    (" " + name_last)))
  end
end
