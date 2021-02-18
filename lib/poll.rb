class Poll
  attr_reader :title, :candidates, :votes, :timelimit

  def initialize(title, candidates, timelimit=nil)
    @title = title
    @candidates = candidates
    @votes = []
    @timelimit = timelimit
  end

  def add_vote(vote)
    if timelimit == nil || timelimit > vote.time
      @votes.push(vote)
    end
  end
end
