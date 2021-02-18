require_relative 'timelimit'

class BordaPoll

  class InvalidCandidateError < StandardError
  end
  class VoteTimeLimitExceededError < StandardError
  end
  class DuplicatedVoteError < StandardError
  end

  attr_reader :title, :candidates, :votes, :timelimit

  def initialize(title, candidates, timelimit=TimeLimit.new("", ""))
    @title = title
    @candidates = candidates.sort
    @votes = []
    @timelimit = timelimit
    @voters = []
  end

  def add_vote(vote)
    if timelimit.exceeded(vote.time)
      raise VoteTimeLimitExceededError
    end
    if @voters.include?(vote.voter)
      raise DuplicatedVoteError
    end
    vote_canditates = vote.candidates.dup.sort
    if @candidates != vote_canditates
      raise InvalidCandidateError
    end
    @votes << vote
    @voters << vote.voter
  end

  def count_votes()
    ret = {}
    @candidates.each do |cand| 
      ret[cand] = 0
    end

    votes.each do |vote|
      score = @candidates.size
      vote.candidates.each do |candidate| 
        ret[candidate] += score
        score -= 1
      end
    end
    ret
  end
end
