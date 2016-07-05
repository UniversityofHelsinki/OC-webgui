require 'pstore'

# Provides a service for logging job-related data that needs to persist through server restarts, but where a DB table would be overkill.
class JobLog
  include Now
  def initialize(jobname)
    @log = PStore.new("app/jobs/logs/#{jobname}.log")
  end

  def log_success
    @log.transaction { @log[:last_success] = now }
  end

  def last_success
    @log.transaction { @log[:last_success] }
  end

  def log_failure
    @log.transaction do
      @log[:failures] = {} unless @log[:failures]
      failures = @log[:failures][Time.zone.today.to_s] || []
      failures.push(now)
      @log[:failures][Time.zone.today.to_s] = failures
    end
  end

  def failures
    @log.transaction do
      @log[:failures] = {} unless @log[:failures]
      @log[:failures]
    end
  end
end
