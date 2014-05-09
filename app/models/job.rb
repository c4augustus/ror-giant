class Job
  include Mongoid::Document
  field :title, type: String
  field :identification, type: String
  field :location, type: String
  field :work_schedule, type: String
  field :start_date, type: Date
  field :pay_rate, type: String
  field :description, type: String
end
