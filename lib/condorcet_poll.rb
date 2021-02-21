require_relative 'timelimit'
require_relative 'multipoll_validator'

class CondorcetPoll
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


  # 計算量の改善が出来そう
  def winner
    loosers = @store.candidates.map { |cand| [cand, false] }.to_h
    @store.candidates.combination(2).each do |cand1, cand2|
      looser1on1(cand1, cand2, @store.votes.map { |vote| vote.candidates }).each do |looser|
        loosers[looser] = true
      end
    end
    loosers.each do |cand, loose|
      unless loose
        return cand
      end
    end
    return nil
  end
end

def looser1on1(cand1, cand2, votes)
  win1 = 0
  win2 = 0
  votes.each do |vote|
    if vote.find_index(cand1) < vote.find_index(cand2)
      win1 += 1
    else
      win2 += 1
    end
  end
  if win1 == win2
    [cand1, cand2]
  elsif win1 > win2
    [cand2]
  else
    [cand1]
  end
end
