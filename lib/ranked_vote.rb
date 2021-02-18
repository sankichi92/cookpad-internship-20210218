require 'date'

class RankedVote
  attr_reader :voter, :candidates

  class EmptyNameError < StandardError
  end

  def initialize(voter, candidates)
    if voter == ''
      raise EmptyNameError
    end
    @voter = voter
    @candidates = candidates
  end
end
