class Poll
  class InvalidCandidateError < StandardError
  end
  class MultipleVoteError < StandardError
  end

  attr_reader :title, :candidates, :votes, :closing

  def initialize(title, candidates, closing)
    @title = title
    @candidates = candidates
    @closing = closing
    @votes = []
  end

  def add_vote(vote)
    unless @candidates.include?(vote.candidate) then
      raise InvalidCandidateError.new(vote.candidate)
    end

    if @votes.map {|element| element.voter }.include?(vote.voter) then
      raise MultipleVoteError.new(vote)
    end

    @votes.push(vote)
  end
end
