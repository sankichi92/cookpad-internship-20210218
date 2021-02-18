class Poll

  class InvalidCandidateError < StandardError
  end

  attr_reader :title, :candidates, :votes, :timelimit

  def initialize(title, candidates, timelimit=nil)
    @title = title
    @candidates = candidates
    @votes = []
    @timelimit = timelimit
  end

  def add_vote(vote)
    if timelimit == nil || timelimit > vote.time
      @votes << vote
    end
    unless @candidates.include?(vote.candidate)
      raise InvalidCandidateError
    end
  end

  def count_votes()
    ret = {}
    @candidates.each do |cand| 
      ret[cand] = 0
    end
    votes.each do |vote|
      ret[vote.candidate] += 1
    end
    ret
  end
end
