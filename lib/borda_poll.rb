require_relative 'timelimit'
require_relative 'multipoll_validator'

class BordaPoll
  def title
    @store.title
  end

  def candidates
    @store.candidates
  end

  def add_vote(vote)
    @store.add_vote(vote)
  end

  def votes
    @store.votes
  end

  def initialize(title, candidates, timelimit=TimeLimit.new("", ""))
    @store = MultiPollValidator.new(title, candidates, timelimit)
  end

  def count_votes()
    ret = {}
    @store.candidates.each do |cand| 
      ret[cand] = 0
    end

    votes.each do |vote|
      score = @store.candidates.size
      vote.candidates.each do |candidate| 
        ret[candidate] += score
        score -= 1
      end
    end
    ret
  end
end
