class Job
  include Mongoid::Document
  has_many :job_application
  has_many :job_referral
  field :id_scheme_ext,   type: String
  field :category,        type: String
  field :title,           type: String
  field :location,        type: String
  field :employment_type, type: String
  field :start_date,      type: Date
  field :pay_rate,        type: String
  field :salary,          type: String
  field :salary_unit,     type: String
  field :description,     type: String

  def self.categories
    @@categories ||= ['ALL', 'CREATIVE', 'INTERACTIVE', 'MARKETING']
  end

  def self.category_matching(string)
    unless string.blank?
      regexp = /#{string.split[0]}/i
      self.categories.each do |category|
        return category if regexp.match category
      end
    end
    nil
  end

  def apply(attributes)
    JobApplication.build(attributes.merge!({job: self}))
  end

  def refer(attributes)
    JobReferral.create(attributes.merge!({job: self}))
  end

end
