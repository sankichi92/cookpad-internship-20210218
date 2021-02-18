class RankedVote
  attr_reader :voter, :candidates
  
  def initialize(voter, candidates) 
    @voter = voter
    @candidates = candidates
  end
end
