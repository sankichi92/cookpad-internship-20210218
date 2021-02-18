class Poll
  attr_reader :title, :candidates, :votes, :timelimit

  def initialize(title, candidates, timelimit=nil)
    @title = title
    @candidates = candidates
    @votes = []
    @timelimit = timelimit
  end

  def add_vote(vote)
    @votes.push(vote)
  end
end
