require_relative '../lib/ranked_vote'

RSpec.describe RankedVote do
    it 'has a voter and a candidate' do
        vote = RankedVote.new('Miyoshi', ['Alice', 'Bob'])

        expect(vote.voter).to eq 'Miyoshi'
        expect(vote.orderedCandidates).to eq ['Alice', 'Bob']
    end
end