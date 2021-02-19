require 'set'

class BordaPoll
  class InvalidCandidateError < StandardError
  end
  class MultipleVoteError < StandardError
  end
  class OverdueVoteError < StandardError
  end

  attr_reader :title, :candidates, :votes, :closing

  def initialize(title, candidates, closing)
    @title = title
    @candidates = candidates
    @closing = closing
    @votes = []
  end

  def add_vote(vote)
    unless (vote.candidates.to_set ^ @candidates.to_set).length == 0 then
      raise InvalidCandidateError.new(vote.candidates)
    end

    if @votes.map { |element| element.voter }.include?(vote.voter) then
      raise MultipleVoteError.new(vote)
    end

    if DateTime.now() > closing then
      raise OverdueVoteError.new(closing)
    end

    @votes.push(vote)
  end

  def count_votes
    votedCandidates = @votes.map { |element| element.candidates }
    result = Hash.new(0)
    votedCandidates.each do |rankedCandidates|
      rankedCandidates.each_with_index do |candidate, i|
        result[candidate] += candidates.length - i
      end
    end
    result
  end
end
