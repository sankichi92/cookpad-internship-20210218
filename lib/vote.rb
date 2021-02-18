require 'date'

class Vote
  attr_reader :voter, :candidate, :time

  class EmptyNameError < StandardError
  end

  def initialize(voter, candidate, time=nil)
    if voter.size == 0
      raise EmptyNameError
    end
    @voter = voter
    @candidate = candidate
    if time == nil
      @time = DateTime.now
    else
      @time = time
    end
  end
end
