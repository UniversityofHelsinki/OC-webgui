# Quick syntax for current time rounded down to closest second
module Now
  def now
    Time.zone.at(Time.zone.now.to_i)
  end
end
