class Vote
  attr_reader :voter, :candidate

  def initialize(voter, candidate)
    @voter = voter
    @candidate = candidate
  end
end
