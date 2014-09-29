class TalentRequest
  include Mongoid::Document
  field :name,      type: String
  field :company,   type: String
  field :email,     type: String
  field :phone,     type: String
  field :what,      type: String
end
