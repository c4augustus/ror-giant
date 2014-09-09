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
  field :attachment_resume,             type: String
  field :attachment_portfolio,          type: String
end
