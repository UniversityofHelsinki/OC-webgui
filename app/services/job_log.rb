require 'pstore'

class JobLog
  def initialize(jobname)
    @jobname = jobname
    @log = PStore.new("app/jobs/logs/#{jobname}.log")
  end

  def log_success
    @log.transaction { @log[:last_success] = Time.zone.at(Time.zone.now.to_i) }
  end

  def last_success
    @log.transaction { @log[:last_success] }
  end

  def log_failure
    @log.transaction do
      @log[:failures] = {} unless @log[:failures]
      failures = @log[:failures][Time.zone.today.to_s] || []
      failures.push(Time.zone.now.to_i)
      @log[:failures][Time.zone.today.to_s] = failures
    end
  end

  def get_failures(date)
    @log.transaction do
      @log[:failures] = {} unless @log[:failures]
      @log[:failures][date.to_s]
    end
  end
end
