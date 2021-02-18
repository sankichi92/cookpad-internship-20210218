require_relative '../lib/ranked_vote'

RSpec.describe RankedVote do
  it 'has a voter and candidates' do
    vote = RankedVote.new('Miyoshi', %w(Alice Bob))

    expect(vote.voter).to eq 'Miyoshi'
    expect(vote.candidates).to eq %w(Alice Bob)
  end
end
