class Poll
  class InvalidCandidateError < StandardError
  end

  attr_reader :title, :candidates, :votes

  def initialize(title, candidates)
    @title = title
    @candidates = candidates
    @votes = []
  end

  def add_vote(vote)
    if not @candidates.include?(vote.candidate) then
      raise InvalidCandidateError.new(vote.candidate)
    end

    @votes.push(vote)
  end
end
