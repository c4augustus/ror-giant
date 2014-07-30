class Job
  include Mongoid::Document
  field :id_scheme_ext, type: String
  field :title, type: String
  field :location, type: String
  field :employment_type, type: String
  field :start_date, type: Date
  field :pay_rate, type: String
  field :salary, type: String
  field :salary_unit, type: String
  field :description, type: String
end
