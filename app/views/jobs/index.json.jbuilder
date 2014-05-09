json.array!(@jobs) do |job|
  json.extract! job, :id, :title, :identification, :location, :work_schedule, :start_date, :pay_rate, :description
  json.url job_url(job, format: :json)
end
