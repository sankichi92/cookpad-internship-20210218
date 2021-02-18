require 'date'

class Vote
  attr_reader :voter, :candidate, :time

  def initialize(voter, candidate, time=nil)
    @voter = voter
    @candidate = candidate
    if time == nil
      @time = DateTime.now
    else
      @time = time
    end
  end
end
