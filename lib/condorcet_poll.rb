require 'set'

class CondorcetPoll
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

    # calc score max candidates
    scores = Hash.new(0)
    votedCandidates.each do |rankedCandidates|
      rankedCandidates.each_with_index do |candidate, i|
        scores[candidate] += candidates.length - i
      end
    end

    scoreRanking = scores.sort { |lhs, rhs| lhs[1] <=> rhs[1] }.reverse
    highScore = scoreRanking[0][1]
    highScoreCandidates = scoreRanking.select { |candidate| candidate[1] == highScore }
                                  .map { |element| element[0] }

    if highScoreCandidates.length == 1 then
      return highScoreCandidates
    end

    # calc win max candidates in score max candidates
    wins = Hash.new{ |hash, key| hash[key] = Hash.new(0) }

    votedCandidates.each do |rankedCandidates|
      rankedCandidates.each_with_index do |candidate1, i|
        rankedCandidates.each_with_index do |candidate2, j|
          if i < j then
            wins[candidate1][candidate2] += 1
            wins[candidate2][candidate1] -= 1
          elsif i > j then
            wins[candidate1][candidate2] -= 1
            wins[candidate2][candidate1] += 1
          end
        end
      end
    end

    result = highScoreCandidates
    loop do
        newResult = result.permutation(2)
                          .select { |pair| wins[pair[0]][pair[1]] > 0 }
                          .map { |pair| pair[0] }
                          .uniq
        break if newResult.length == 0 || newResult.length == result.length
        result = newResult
    end
    result
  end
end
