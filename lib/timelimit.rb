class TimeLimit

  attr_reader :time

  @time
  def initialize(date, time)
    if date == "" && time == ""
      @time = nil
    elsif date != "" && time != ""
      @time = Time.parse(date + " " + time + ":00" "+0900")
    elsif date != ""
      @time = Time.parse(date + " 23:59:59 +0900")
    else
      now = Time.now
      @time = Time.parse("#{now.year}-#{now.month}-#{now.day} " + time + "+0900")
    end
  end

  def exceeded(time)
    if @time == nil
      false
    else
      @time < time
    end
  end
end
