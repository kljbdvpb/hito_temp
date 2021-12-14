if Delayed::Job.table_exists? && !Rails.env.test?
  # schedule cron jobs here
  MemberPaymentStatusJob.new.schedule
end
