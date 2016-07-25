app_path = File.expand_path(File.join(File.dirname(__FILE__), ''))

God.watch do |w|
  w.name   = 'backburner'
  w.dir    = app_path
  w.env = { 'ORANGE_CONTACT_PASSWORD' => ENV['ORANGE_CONTACT_PASSWORD'] }
  w.interval = 30.seconds
  w.start = 'bundle exec rake -f Rakefile backburner:work'
  w.log   = 'log/backburner.log'

  # restart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = 120.megabytes
      c.times = 4
    end
  end

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end

God.watch do |w|
  w.name   = 'clockwork'
  w.dir    = app_path
  w.env = { 'ORANGE_CONTACT_PASSWORD' => ENV['ORANGE_CONTACT_PASSWORD'] }
  w.interval = 30.seconds
  w.start = 'clockwork app/jobs/schedule.rb'
  w.log   = 'log/clockwork.log'

  # restart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = 100.megabytes
      c.times = 3
    end
  end

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end

God.watch do |w|
  w.name   = 'rails'
  w.dir    = app_path
  w.env = { 'ORANGE_CONTACT_PASSWORD' => ENV['ORANGE_CONTACT_PASSWORD'] }
  w.interval = 30.seconds
  w.start = 'rails s'
  w.log   = 'log/rails.log'

  # restart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = 1024.megabytes
      c.times = 5
    end
  end

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end
