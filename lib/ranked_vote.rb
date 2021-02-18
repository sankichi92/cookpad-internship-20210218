class RankedVote
    attr_reader :voter, :orderedCandidates

    def initialize(voter, orderedCandidates)
        @voter = voter
        @orderedCandidates = orderedCandidates
    end
end