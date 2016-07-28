Backburner.configure do |config|
  config.tube_namespace      = "ocwebgui"
  config.max_job_retries     = 0
  config.respond_timeout     = 2400
  config.default_worker      = Backburner::Workers::Simple
  config.logger              = Logger.new(STDOUT)
  config.primary_queue       = "backburner-jobs"
  config.reserve_timeout     = nil
end
