require 'date'

class BordaPoll
  class InvalidCandidateError < StandardError
  end

  class DuplicatedVoterError < StandardError
  end

  class VoteToExpiredPollError < StandardError
  end

  attr_reader :title, :candidates, :expiresAt, :votes
  def initialize(title, candidates, expiresAt = Date.today + 1)
    @title = title
    @candidates = candidates
    @expiresAt = expiresAt
    @votes = []
  end

  def add_vote(rankedVote)
    unless rankedVote.orderedCandidates.sort == candidates.sort
      raise InvalidCandidateError
    end
    if votes.map { |v| v.voter }.include?(rankedVote.voter)
      raise DuplicatedVoterError
    end
    if @expiresAt < Date.today
      raise VoteToExpiredPollError
    end
    @votes.push(rankedVote)
  end

  def count_votes
    res = Hash.new(0)
    @candidates.each { |candidate| res[candidate] = 0 }
    @votes.each do |vote|
      vote.orderedCandidates.each_with_index do |candidate, index|
        res[candidate] += candidates.length - index
      end
    end
    res
  end
end
