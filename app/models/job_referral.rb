class JobReferral
  include Mongoid::Document
  belongs_to :job
  field :email,   type: String
  field :name,    type: String
  field :subject, type: String
  field :body,    type: String
end
