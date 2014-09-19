class Job
  include Mongoid::Document
  has_many :job_application
  has_many :job_referral
  field :id_scheme_ext,   type: String
  field :title,           type: String
  field :location,        type: String
  field :employment_type, type: String
  field :start_date,      type: Date
  field :pay_rate,        type: String
  field :salary,          type: String
  field :salary_unit,     type: String
  field :description,     type: String

  def self.categories
    @@categories ||= ['UXD', 'CREATIVE', 'MARKETING']
  end

  def category
    "CREATIVE"
  end

  def apply(attributes)
    JobApplication.create(attributes.merge!({job: self}))
  end

  def refer(attributes)
    JobReferral.create(attributes.merge!({job: self}))
  end

end
