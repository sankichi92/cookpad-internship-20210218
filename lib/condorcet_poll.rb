require 'date'

class CondorcetPoll
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
        if votes.map {|v| v.voter}.include?(rankedVote.voter)
            raise DuplicatedVoterError
        end
        if @expiresAt < Date.today
            raise VoteToExpiredPollError
        end
        @votes.push(rankedVote)
    end

    def get_winner
        candidateWins = {}
        @candidates.each { |candidate| candidateWins[candidate] = 0 }
        @candidates.combination(2).each do |comb|
            cand0cnt = 0
            cand1cnt = 0
            cand0 = comb[0]
            cand1 = comb[1]
            @votes.each do |vote|
                ind0 = vote.orderedCandidates.index(comb[0])
                ind1 = vote.orderedCandidates.index(comb[1])
                if ind0 < ind1
                    cand0cnt += 1
                else
                    cand1cnt += 1
                end
            end
            if cand0cnt > cand1cnt
                candidateWins[cand0] += 1
            elsif cand0cnt < cand1cnt
                candidateWins[cand1] += 1
            end
        end

        candidateWins.select { |k, v| v == @candidates.length - 1 }.map {|k, v| k}[0]
    end
end