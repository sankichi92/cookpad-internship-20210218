class Poll
  class InvalidCandidateError < StandardError
  end
  class MultipleVoteError < StandardError
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

    if @votes.map {|element| element.voter }.include?(vote.voter) then
      raise MultipleVoteError.new(vote)
    end

    @votes.push(vote)
  end
end
