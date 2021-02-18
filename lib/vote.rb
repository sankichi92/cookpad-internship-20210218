require 'date'

class Vote
  attr_reader :voter, :candidate, :time

  class EmptyNameError < StandardError
  end

  def initialize(voter, candidate)
    if voter.size == 0
      raise EmptyNameError
    end
    @voter = voter
    @candidate = candidate
    @time = Time.now
  end
end
